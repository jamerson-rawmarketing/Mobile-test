#!/bin/bash
# Setup WordPress with SQLite (no MySQL/Docker needed)
set -e

WP_DIR="wordpress"
WP_PORT="${WP_PORT:-8080}"

echo "==> Baixando WP-CLI..."
curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar

echo "==> Baixando WordPress (pt_BR)..."
php wp-cli.phar core download --path="$WP_DIR" --locale=pt_BR --allow-root

echo "==> Instalando plugin SQLite Database Integration..."
curl -sL "https://downloads.wordpress.org/plugin/sqlite-database-integration.latest-stable.zip" -o /tmp/sqlite-plugin.zip
unzip -q /tmp/sqlite-plugin.zip -d "$WP_DIR/wp-content/plugins/"
cp "$WP_DIR/wp-content/plugins/sqlite-database-integration/db.copy" "$WP_DIR/wp-content/db.php"

echo "==> Gerando wp-config.php..."
SALTS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
cat > "$WP_DIR/wp-config.php" << WPCONFIG
<?php
define('DB_NAME', 'wordpress');
define('DB_USER', 'wpuser');
define('DB_PASSWORD', 'wppassword');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

$SALTS

\$table_prefix = 'wp_';
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', false);

if (!defined('ABSPATH')) define('ABSPATH', __DIR__ . '/');
require_once ABSPATH . 'wp-settings.php';
WPCONFIG

echo "==> Instalando WordPress..."
php wp-cli.phar core install \
  --path="$WP_DIR" \
  --url="http://localhost:$WP_PORT" \
  --title="Meu Site de Teste" \
  --admin_user="admin" \
  --admin_password="admin123" \
  --admin_email="admin@example.com" \
  --allow-root

echo ""
echo "✓ WordPress pronto!"
echo "  Site:  http://localhost:$WP_PORT"
echo "  Admin: http://localhost:$WP_PORT/wp-admin"
echo "  Login: admin / admin123"
echo ""
echo "==> Iniciando servidor PHP..."
cd "$WP_DIR" && php -S "0.0.0.0:$WP_PORT"
