<?php
unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mariadb';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'moodle-db';
$CFG->dbname    = getenv('DB_NAME') ?: 'moodle_erasmus';
$CFG->dbuser    = getenv('DB_USER') ?: 'moodle_user';
$CFG->dbpass    = getenv('DB_PASSWORD') ?: 'moodle_secure_password';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array(
  'dbpersist' => 0,
  'dbport' => '',
  'dbsocket' => '',
  'dbcollation' => 'utf8mb4_unicode_ci',
);

// Read the URL from the .env dynamically!
$CFG->wwwroot   = getenv('EXTERNAL_ROOT_URL') ?: 'http://localhost:8080';
$CFG->dataroot  = '/var/www/moodledata';
$CFG->admin     = 'admin';
$CFG->directorypermissions = 02777;

// If using HTTPS (staging/prod), Moodle needs to know it's behind a proxy
if (strpos($CFG->wwwroot, 'https://') === 0) {
    $CFG->sslproxy = true;
}

// Let Moodle know that we configured the Moodle Router (with the 99-moodle-router.sh entrypoint script)
$CFG->routerconfigured = true;

// Enable Slash Arguments (vital for modern routing, images, and SCORM packages)
$CFG->slasharguments = true;

// Performance optimization: Use native Linux command to calculate directory sizes
$CFG->pathtodu = '/usr/bin/du';

require_once(__DIR__ . '/lib/setup.php');

require_once(__DIR__ . '/lib/setup.php');