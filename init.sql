CREATE USER jetbrains with encrypted password 'mypass123';
CREATE DATABASE teamcity;
GRANT ALL PRIVILEGES ON DATABASE teamcity TO jetbrains;
