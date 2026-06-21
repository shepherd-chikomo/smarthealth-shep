package dev.smarthealth.smarthealth_shep

import android.content.ContentUris
import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.DocumentsContract
import android.content.pm.PackageManager
import android.media.MediaScannerConnection
import android.provider.MediaStore
import android.provider.MediaStore.Files
import android.provider.MediaStore.Files.FileColumns
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveToHealthVault" -> {
                    val fileName = call.argument<String>("fileName")
                    val content = call.argument<String>("content")
                    if (fileName.isNullOrBlank() || content == null) {
                        result.error("INVALID", "fileName and content required", null)
                        return@setMethodCallHandler
                    }
                    try {
                        result.success(saveToHealthVault(fileName, content))
                    } catch (error: Exception) {
                        result.error("SAVE_FAILED", error.message, null)
                    }
                }
                "openHealthVaultFolder" -> {
                    result.success(openHealthVaultFolder())
                }
                "listHealthVaultBackups" -> {
                    Thread {
                        try {
                            val backups = listHealthVaultBackupsInternal()
                            runOnUiThread { result.success(backups) }
                        } catch (error: Exception) {
                            runOnUiThread {
                                result.error("LIST_FAILED", error.message, null)
                            }
                        }
                    }.start()
                }
                "readHealthVaultFile" -> {
                    val uri = call.argument<String>("uri")
                    val path = call.argument<String>("path")
                    try {
                        result.success(readHealthVaultFile(uri, path))
                    } catch (error: Exception) {
                        result.error("READ_FAILED", error.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun saveToHealthVault(fileName: String, content: String): Map<String, Any?> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val resolver = contentResolver
            val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
            deleteExistingDownload(resolver, collection, fileName)

            val pending = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(MediaStore.MediaColumns.MIME_TYPE, "application/x-healthvault")
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH,
                    "${Environment.DIRECTORY_DOWNLOADS}/$HEALTH_VAULT_DIR",
                )
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }

            val uri = resolver.insert(collection, pending)
                ?: throw IOException("Could not create backup in Downloads/$HEALTH_VAULT_DIR")

            resolver.openOutputStream(uri)?.use { stream ->
                stream.write(content.toByteArray(Charsets.UTF_8))
            } ?: throw IOException("Could not write backup file")

            val published = ContentValues().apply {
                put(MediaStore.MediaColumns.IS_PENDING, 0)
            }
            resolver.update(uri, published, null, null)

            registerBackupInCatalog(fileName, uri, System.currentTimeMillis())

            return mapOf(
                "path" to "$PUBLIC_FOLDER_PATH/$fileName",
                "uri" to uri.toString(),
            )
        }

        @Suppress("DEPRECATION")
        val downloads = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        val vaultDir = File(downloads, HEALTH_VAULT_DIR)
        if (!vaultDir.exists() && !vaultDir.mkdirs()) {
            throw IOException("Could not create Downloads/$HEALTH_VAULT_DIR")
        }
        val file = File(vaultDir, fileName)
        file.writeText(content, Charsets.UTF_8)
        registerBackupInCatalog(fileName, Uri.fromFile(file), file.lastModified())
        return mapOf(
            "path" to file.absolutePath,
            "uri" to Uri.fromFile(file).toString(),
        )
    }

    private fun deleteExistingDownload(
        resolver: android.content.ContentResolver,
        collection: Uri,
        fileName: String,
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return
        val projection = arrayOf(MediaStore.MediaColumns._ID)
        val selection =
            "${MediaStore.MediaColumns.DISPLAY_NAME}=? AND ${MediaStore.MediaColumns.RELATIVE_PATH}=?"
        val selectionArgs = arrayOf(
            fileName,
            "${Environment.DIRECTORY_DOWNLOADS}/$HEALTH_VAULT_DIR/",
        )
        resolver.query(collection, projection, selection, selectionArgs, null)?.use { cursor ->
            val idColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID)
            while (cursor.moveToNext()) {
                val id = cursor.getLong(idColumn)
                val deleteUri = ContentUris.withAppendedId(collection, id)
                resolver.delete(deleteUri, null, null)
            }
        }
    }

    private fun openHealthVaultFolder(): Boolean {
        ensureLegacyFolderExists()
        return try {
            val uri = Uri.parse(
                "content://com.android.externalstorage.documents/document/primary:" +
                    Uri.encode("Download/$HEALTH_VAULT_DIR"),
            )
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, DocumentsContract.Document.MIME_TYPE_DIR)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(intent)
            true
        } catch (_: Exception) {
            try {
                val uri = Uri.parse(
                    "content://com.android.externalstorage.documents/document/primary:" +
                        Uri.encode("Download"),
                )
                val intent = Intent(Intent.ACTION_VIEW).apply {
                    setDataAndType(uri, DocumentsContract.Document.MIME_TYPE_DIR)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(intent)
                true
            } catch (_: Exception) {
                false
            }
        }
    }

    private fun ensureLegacyFolderExists() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) return
        @Suppress("DEPRECATION")
        val downloads = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        File(downloads, HEALTH_VAULT_DIR).mkdirs()
    }

    private fun listHealthVaultBackups(): List<Map<String, Any?>> {
        return try {
            listHealthVaultBackupsInternal()
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun listHealthVaultBackupsInternal(): List<Map<String, Any?>> {
        requestLegacyReadPermissionIfNeeded()

        var results = collectHealthVaultBackupResults()
        if (results.isEmpty()) {
            scanLegacyHealthVaultFiles()
            results = collectHealthVaultBackupResults()
        }

        if (results.isNotEmpty()) {
            persistCatalog(results)
        }

        return results.sortedByDescending { (it["modifiedAt"] as? Long) ?: 0L }
    }

    private fun collectHealthVaultBackupResults(): MutableList<Map<String, Any?>> {
        val results = mutableListOf<Map<String, Any?>>()
        val seen = mutableSetOf<String>()

        appendCatalogEntries(results, seen)
        appendLegacyDownloadResults(results, seen)
        appendHealthVaultRelativeDownloads(results, seen)
        appendRecentDownloadsScan(results, seen)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appendMediaStoreDownloadBackups(
                results,
                seen,
                "${MediaStore.MediaColumns.DISPLAY_NAME} LIKE ?",
                arrayOf("$BACKUP_PREFIX%"),
            )
            appendMediaStoreDownloadBackups(
                results,
                seen,
                "${MediaStore.MediaColumns.DISPLAY_NAME} LIKE ?",
                arrayOf("%.$BACKUP_EXTENSION"),
            )
            appendMediaStoreDownloadBackups(
                results,
                seen,
                "${MediaStore.MediaColumns.DISPLAY_NAME} LIKE ?",
                arrayOf("%.bin"),
            )
            appendMediaStoreFilesBackups(results, seen)
            appendHealthVaultPathFiles(results, seen)
        }

        appendLegacyDownloadResults(results, seen)
        return results
    }

    private fun requestLegacyReadPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) return
        if (ContextCompat.checkSelfPermission(
                this,
                android.Manifest.permission.READ_EXTERNAL_STORAGE,
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            return
        }
        ActivityCompat.requestPermissions(
            this,
            arrayOf(android.Manifest.permission.READ_EXTERNAL_STORAGE),
            READ_STORAGE_REQUEST_CODE,
        )
    }

    private fun appendCatalogEntries(
        results: MutableList<Map<String, Any?>>,
        seen: MutableSet<String>,
    ) {
        val catalogJson = readCatalogJson() ?: return
        try {
            val backups = catalogJson.optJSONArray("backups") ?: return
            for (index in 0 until backups.length()) {
                val entry = backups.optJSONObject(index) ?: continue
                val name = entry.optString("name")
                if (name.isBlank() || !isBackupFileName(name)) continue
                if (!seen.add(name.lowercase())) continue
                val uri = entry.optString("uri").ifBlank { null }
                val modifiedAt = entry.optLong("modifiedAt", System.currentTimeMillis())
                results.add(
                    mapOf(
                        "path" to "$PUBLIC_FOLDER_PATH/$name",
                        "uri" to uri,
                        "modifiedAt" to modifiedAt,
                    ),
                )
            }
        } catch (_: Exception) {
        }
    }

    private fun readCatalogJson(): JSONObject? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
            val projection = arrayOf(MediaStore.MediaColumns._ID)
            val selection = "${MediaStore.MediaColumns.DISPLAY_NAME}=?"
            val selectionArgs = arrayOf(CATALOG_FILE_NAME)
            contentResolver.query(collection, projection, selection, selectionArgs, null)
                ?.use { cursor ->
                    if (!cursor.moveToFirst()) return@use null
                    val id = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID))
                    val uri = ContentUris.withAppendedId(collection, id)
                    val text = contentResolver.openInputStream(uri)?.use { stream ->
                        stream.bufferedReader(Charsets.UTF_8).readText()
                    } ?: return@use null
                    return JSONObject(text)
                }?.let { return it }
        }

        for (dir in healthVaultCandidateDirs()) {
            val catalogFile = File(dir, CATALOG_FILE_NAME)
            if (!catalogFile.isFile) continue
            try {
                return JSONObject(catalogFile.readText(Charsets.UTF_8))
            } catch (_: Exception) {
            }
        }
        return null
    }

    private fun persistCatalog(results: List<Map<String, Any?>>) {
        val backups = JSONArray()
        for (entry in results) {
            val path = entry["path"] as? String ?: continue
            val name = path.substringAfterLast('/')
            if (!isBackupFileName(name)) continue
            backups.put(
                JSONObject().apply {
                    put("name", name)
                    put("uri", entry["uri"] as? String ?: "")
                    put("modifiedAt", (entry["modifiedAt"] as? Long) ?: System.currentTimeMillis())
                },
            )
        }
        if (backups.length() == 0) return

        val payload = JSONObject().put("backups", backups).toString()
        writeCatalogPayload(payload)
    }

    private fun registerBackupInCatalog(fileName: String, uri: Uri, modifiedAt: Long) {
        val existing = readCatalogJson()?.optJSONArray("backups") ?: JSONArray()
        val updated = JSONArray()
        updated.put(
            JSONObject().apply {
                put("name", fileName)
                put("uri", uri.toString())
                put("modifiedAt", modifiedAt)
            },
        )
        for (index in 0 until existing.length()) {
            val entry = existing.optJSONObject(index) ?: continue
            if (entry.optString("name") == fileName) continue
            updated.put(entry)
        }
        writeCatalogPayload(JSONObject().put("backups", updated).toString())
    }

    private fun writeCatalogPayload(payload: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val resolver = contentResolver
            val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
            deleteExistingDownload(resolver, collection, CATALOG_FILE_NAME)

            val pending = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, CATALOG_FILE_NAME)
                put(MediaStore.MediaColumns.MIME_TYPE, "application/json")
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH,
                    "${Environment.DIRECTORY_DOWNLOADS}/$HEALTH_VAULT_DIR",
                )
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            val uri = resolver.insert(collection, pending) ?: return
            resolver.openOutputStream(uri)?.use { stream ->
                stream.write(payload.toByteArray(Charsets.UTF_8))
            }
            val published = ContentValues().apply {
                put(MediaStore.MediaColumns.IS_PENDING, 0)
            }
            resolver.update(uri, published, null, null)
            return
        }

        @Suppress("DEPRECATION")
        val catalogFile = File(
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
            "$HEALTH_VAULT_DIR/$CATALOG_FILE_NAME",
        )
        catalogFile.parentFile?.mkdirs()
        catalogFile.writeText(payload, Charsets.UTF_8)
    }

    private fun appendHealthVaultRelativeDownloads(
        results: MutableList<Map<String, Any?>>,
        seen: MutableSet<String>,
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return
        appendMediaStoreDownloadBackups(
            results,
            seen,
            "${MediaStore.MediaColumns.RELATIVE_PATH} LIKE ? AND ${MediaStore.MediaColumns.DISPLAY_NAME} LIKE ?",
            arrayOf("%$HEALTH_VAULT_DIR%", "$BACKUP_PREFIX%"),
        )
    }

    private fun appendRecentDownloadsScan(
        results: MutableList<Map<String, Any?>>,
        seen: MutableSet<String>,
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return
        val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.MediaColumns._ID,
            MediaStore.MediaColumns.DISPLAY_NAME,
            MediaStore.MediaColumns.DATE_MODIFIED,
        )
        contentResolver.query(
            collection,
            projection,
            null,
            null,
            "${MediaStore.MediaColumns.DATE_MODIFIED} DESC",
        )?.use { cursor ->
            val idColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID)
            val nameColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DISPLAY_NAME)
            val modifiedColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATE_MODIFIED)
            var scanned = 0
            while (cursor.moveToNext() && scanned < 500) {
                scanned++
                val name = cursor.getString(nameColumn) ?: continue
                if (!isBackupFileName(name)) continue
                val dedupeKey = name.lowercase()
                if (!seen.add(dedupeKey)) continue
                val id = cursor.getLong(idColumn)
                val modifiedSeconds = cursor.getLong(modifiedColumn)
                val uri = ContentUris.withAppendedId(collection, id).toString()
                results.add(
                    mapOf(
                        "path" to "$PUBLIC_FOLDER_PATH/$name",
                        "uri" to uri,
                        "modifiedAt" to modifiedSeconds * 1000,
                    ),
                )
            }
        }
    }

    private fun healthVaultCandidateDirs(): List<File> {
        val dirs = mutableListOf<File>()
        @Suppress("DEPRECATION")
        dirs.add(
            File(
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
                HEALTH_VAULT_DIR,
            ),
        )
        dirs.add(File("/storage/emulated/0/Download/HealthVault"))
        dirs.add(File("/storage/emulated/0/Downloads/HealthVault"))
        return dirs
    }

    private fun scanLegacyHealthVaultFiles() {
        val paths = mutableListOf<String>()
        for (dir in healthVaultCandidateDirs()) {
            if (!dir.isDirectory) continue
            dir.listFiles()?.forEach { file ->
                if (file.isFile && isBackupFileName(file.name)) {
                    paths.add(file.absolutePath)
                }
            }
        }
        if (paths.isEmpty()) return
        MediaScannerConnection.scanFile(
            applicationContext,
            paths.toTypedArray(),
            null,
            null,
        )
    }

    private fun appendHealthVaultPathFiles(
        results: MutableList<Map<String, Any?>>,
        seen: MutableSet<String>,
    ) {
        val collection = Files.getContentUri(MediaStore.VOLUME_EXTERNAL)
        val projection = arrayOf(
            FileColumns._ID,
            FileColumns.DISPLAY_NAME,
            FileColumns.DATE_MODIFIED,
            FileColumns.RELATIVE_PATH,
        )
        val selection =
            "(${FileColumns.RELATIVE_PATH} LIKE ? OR ${FileColumns.RELATIVE_PATH} LIKE ?) AND " +
                "(${FileColumns.DISPLAY_NAME} LIKE ? OR ${FileColumns.DISPLAY_NAME} LIKE ? OR " +
                "${FileColumns.DISPLAY_NAME} LIKE ?)"
        val selectionArgs = arrayOf(
            "%/$HEALTH_VAULT_DIR/%",
            "%$HEALTH_VAULT_DIR/%",
            "$BACKUP_PREFIX%",
            "%.$BACKUP_EXTENSION",
            "%.bin",
        )
        contentResolver.query(
            collection,
            projection,
            selection,
            selectionArgs,
            "${FileColumns.DATE_MODIFIED} DESC",
        )?.use { cursor ->
            appendMediaStoreFileCursorRows(results, seen, collection, cursor)
        }
    }

    private fun appendMediaStoreFilesBackups(
        results: MutableList<Map<String, Any?>>,
        seen: MutableSet<String>,
    ) {
        val collection = Files.getContentUri(MediaStore.VOLUME_EXTERNAL)
        val projection = arrayOf(
            FileColumns._ID,
            FileColumns.DISPLAY_NAME,
            FileColumns.DATE_MODIFIED,
        )
        val selection = "${FileColumns.DISPLAY_NAME} LIKE ?"
        val selectionArgs = arrayOf("$BACKUP_PREFIX%")
        contentResolver.query(
            collection,
            projection,
            selection,
            selectionArgs,
            "${FileColumns.DATE_MODIFIED} DESC",
        )?.use { cursor ->
            appendMediaStoreFileCursorRows(results, seen, collection, cursor)
        }
    }

    private fun appendMediaStoreFileCursorRows(
        results: MutableList<Map<String, Any?>>,
        seen: MutableSet<String>,
        collection: Uri,
        cursor: android.database.Cursor,
    ) {
        val idColumn = cursor.getColumnIndexOrThrow(FileColumns._ID)
        val nameColumn = cursor.getColumnIndexOrThrow(FileColumns.DISPLAY_NAME)
        val modifiedColumn = cursor.getColumnIndexOrThrow(FileColumns.DATE_MODIFIED)
        while (cursor.moveToNext()) {
            val name = cursor.getString(nameColumn) ?: continue
            if (!isBackupFileName(name)) continue
            val dedupeKey = name.lowercase()
            if (!seen.add(dedupeKey)) continue
            val id = cursor.getLong(idColumn)
            val modifiedSeconds = cursor.getLong(modifiedColumn)
            val uri = ContentUris.withAppendedId(collection, id).toString()
            results.add(
                mapOf(
                    "path" to "$PUBLIC_FOLDER_PATH/$name",
                    "uri" to uri,
                    "modifiedAt" to modifiedSeconds * 1000,
                ),
            )
        }
    }

    private fun appendMediaStoreDownloadBackups(
        results: MutableList<Map<String, Any?>>,
        seen: MutableSet<String>,
        selection: String,
        selectionArgs: Array<String>,
    ) {
        val resolver = contentResolver
        val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.MediaColumns._ID,
            MediaStore.MediaColumns.DISPLAY_NAME,
            MediaStore.MediaColumns.DATE_MODIFIED,
            MediaStore.MediaColumns.RELATIVE_PATH,
        )
        resolver.query(
            collection,
            projection,
            selection,
            selectionArgs,
            "${MediaStore.MediaColumns.DATE_MODIFIED} DESC",
        )?.use { cursor ->
            val idColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID)
            val nameColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DISPLAY_NAME)
            val modifiedColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATE_MODIFIED)
            while (cursor.moveToNext()) {
                val name = cursor.getString(nameColumn) ?: continue
                if (!isBackupFileName(name)) continue
                val dedupeKey = name.lowercase()
                if (!seen.add(dedupeKey)) continue
                val id = cursor.getLong(idColumn)
                val modifiedSeconds = cursor.getLong(modifiedColumn)
                val uri = ContentUris.withAppendedId(collection, id).toString()
                results.add(
                    mapOf(
                        "path" to "$PUBLIC_FOLDER_PATH/$name",
                        "uri" to uri,
                        "modifiedAt" to modifiedSeconds * 1000,
                    ),
                )
            }
        }
    }

    private fun isBackupFileName(name: String): Boolean {
        val lower = name.lowercase()
        if (lower == CATALOG_FILE_NAME) return false
        if (lower.startsWith(BACKUP_PREFIX)) return true
        if (lower.endsWith(".$BACKUP_EXTENSION")) return true
        return lower.contains("healthvault") &&
            (lower.startsWith("myhealth") || lower.contains("backup"))
    }

    @Suppress("DEPRECATION")
    private fun appendLegacyDownloadResults(
        results: MutableList<Map<String, Any?>>,
        seen: MutableSet<String>,
    ) {
        for (vaultDir in healthVaultCandidateDirs()) {
            if (!vaultDir.isDirectory) continue
            vaultDir.listFiles()?.sortedByDescending { it.lastModified() }?.forEach { file ->
                if (!file.isFile) return@forEach
                val name = file.name
                if (!isBackupFileName(name)) return@forEach
                if (!seen.add(name.lowercase())) return@forEach
                results.add(
                    mapOf(
                        "path" to "$PUBLIC_FOLDER_PATH/$name",
                        "uri" to Uri.fromFile(file).toString(),
                        "modifiedAt" to file.lastModified(),
                    ),
                )
            }
        }
    }

    private fun readHealthVaultFile(uriString: String?, path: String?): String {
        if (!uriString.isNullOrBlank()) {
            val uri = Uri.parse(uriString)
            if (uri.scheme == "file") {
                val filePath = uri.path
                if (!filePath.isNullOrBlank()) {
                    return File(filePath).readText(Charsets.UTF_8)
                }
            }
            return contentResolver.openInputStream(uri)?.use { stream ->
                stream.bufferedReader(Charsets.UTF_8).readText()
            } ?: throw IOException("Could not read backup file")
        }
        if (!path.isNullOrBlank()) {
            val file = File(path)
            if (file.exists()) {
                return file.readText(Charsets.UTF_8)
            }
            throw IOException("Backup file not found at $path")
        }
        throw IOException("uri or path required")
    }

    companion object {
        private const val CHANNEL = "dev.smarthealth.smarthealth_shep/files"
        private const val HEALTH_VAULT_DIR = "HealthVault"
        private const val PUBLIC_FOLDER_PATH = "Download/HealthVault"
        private const val BACKUP_PREFIX = "myhealth_backup_"
        private const val BACKUP_EXTENSION = "healthvault"
        private const val CATALOG_FILE_NAME = "healthvault_catalog.json"
        private const val READ_STORAGE_REQUEST_CODE = 9101
    }
}
