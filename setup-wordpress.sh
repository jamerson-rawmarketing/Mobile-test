#!/bin/bash
# Setup WordPress with SQLite (no MySQL/Docker needed)
set -e

WP_DIR="wordpress"
WP_PORT="${WP_PORT:-8080}"

echo "==> Baixando WP-CLI..."
curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar

echo "==> Baixando WordPress (pt_BR)..."
php wp-cli.phar core download --path="$WP_DIR" --locale=pt_BR --force

echo "==> Instalando plugin SQLite Database Integration..."
curl -sL "https://downloads.wordpress.org/plugin/sqlite-database-integration.latest-stable.zip" -o /tmp/sqlite-plugin.zip
unzip -q -o /tmp/sqlite-plugin.zip -d "$WP_DIR/wp-content/plugins/"
cp "$WP_DIR/wp-content/plugins/sqlite-database-integration/db.copy" "$WP_DIR/wp-content/db.php"
mkdir -p "$WP_DIR/wp-content/database"

echo "==> Gerando wp-config.php..."
php wp-cli.phar config create \
  --path="$WP_DIR" \
  --dbname=wordpress \
  --dbuser=wpuser \
  --dbpass=wppassword \
  --dbhost=localhost \
  --skip-check \
  --force

php wp-cli.phar config set WP_DEBUG true --raw --path="$WP_DIR"
php wp-cli.phar config set WP_DEBUG_LOG true --raw --path="$WP_DIR"
php wp-cli.phar config set WP_DEBUG_DISPLAY false --raw --path="$WP_DIR"

echo "==> Instalando WordPress..."
php wp-cli.phar core install \
  --path="$WP_DIR" \
  --url="http://localhost:$WP_PORT" \
  --title="Meu Site de Teste" \
  --admin_user="admin" \
  --admin_password="admin123" \
  --admin_email="admin@example.com"

echo ""
echo "=================================="
echo "  WordPress pronto!"
echo "  Site:  http://localhost:$WP_PORT"
echo "  Admin: http://localhost:$WP_PORT/wp-admin"
echo "  Login: admin / admin123"
echo "=================================="
echo ""
echo "Iniciando servidor... (Ctrl+C para parar)"
cd "$WP_DIR" && php -S "0.0.0.0:$WP_PORT"
