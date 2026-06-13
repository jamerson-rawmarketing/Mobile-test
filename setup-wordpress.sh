#!/bin/bash
# Setup WordPress with SQLite — sem WP-CLI, sem MySQL
set -e

WP_DIR="wordpress"
WP_PORT="${WP_PORT:-8080}"

echo "==> Limpando instalação anterior..."
rm -rf "$WP_DIR" wp-cli.phar

echo "==> Baixando WordPress..."
curl -L "https://br.wordpress.org/latest-pt_BR.zip" -o /tmp/wordpress.zip
echo "==> Extraindo..."
unzip -q /tmp/wordpress.zip -d /tmp/wp-extract
mv /tmp/wp-extract/wordpress "$WP_DIR"

echo "==> Instalando SQLite Database Integration..."
curl -sL "https://downloads.wordpress.org/plugin/sqlite-database-integration.latest-stable.zip" -o /tmp/sqlite-plugin.zip
unzip -q -o /tmp/sqlite-plugin.zip -d "$WP_DIR/wp-content/plugins/"
cp "$WP_DIR/wp-content/plugins/sqlite-database-integration/db.copy" "$WP_DIR/wp-content/db.php"
mkdir -p "$WP_DIR/wp-content/database"

echo "==> Criando wp-config.php..."
php -r "
\$chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()-_=+[]{}|;:,.<>?';
function salt() {
    global \$chars;
    \$s = '';
    for (\$i = 0; \$i < 64; \$i++) \$s .= \$chars[random_int(0, strlen(\$chars)-1)];
    return \$s;
}
\$keys = ['AUTH_KEY','SECURE_AUTH_KEY','LOGGED_IN_KEY','NONCE_KEY','AUTH_SALT','SECURE_AUTH_SALT','LOGGED_IN_SALT','NONCE_SALT'];
\$salts = '';
foreach (\$keys as \$k) \$salts .= \"define('{\$k}', '\" . salt() . \"');\n\";

\$config = file_get_contents('$WP_DIR/wp-config-sample.php');
\$config = str_replace(\"define( 'DB_NAME', 'database_name_here' );\", \"define( 'DB_NAME', 'wordpress' );\", \$config);
\$config = str_replace(\"define( 'DB_USER', 'username_here' );\", \"define( 'DB_USER', 'wpuser' );\", \$config);
\$config = str_replace(\"define( 'DB_PASSWORD', 'password_here' );\", \"define( 'DB_PASSWORD', 'wppassword' );\", \$config);
\$config = preg_replace(\"/define\( 'AUTH_KEY'.*?NONCE_SALT.*?'\s*\);\s*/s\", \$salts, \$config);
\$config = str_replace(\"/* Add any custom values between this line\", \"define('WP_DEBUG', true);\ndefine('WP_DEBUG_LOG', true);\ndefine('WP_DEBUG_DISPLAY', false);\n\n/* Add any custom values between this line\", \$config);
file_put_contents('$WP_DIR/wp-config.php', \$config);
echo 'wp-config.php criado.' . PHP_EOL;
"

echo ""
echo "=================================="
echo "  WordPress pronto!"
echo ""
echo "  1. Acesse: http://localhost:$WP_PORT/wp-admin/install.php"
echo "  2. Escolha o idioma (Português do Brasil)"
echo "  3. Preencha o título e crie seu usuário"
echo "=================================="
echo ""
echo "Iniciando servidor... (Ctrl+C para parar)"
cd "$WP_DIR" && php -S "0.0.0.0:$WP_PORT"
