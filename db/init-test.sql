CREATE DATABASE IF NOT EXISTS expense_system_test
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

GRANT ALL PRIVILEGES ON expense_system_test.*
  TO 'expense_user'@'%';

FLUSH PRIVILEGES;
