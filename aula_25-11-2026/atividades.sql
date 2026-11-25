-- Banco de dados do sistema de atividades do dia (aula 25/11/2026)
-- Importar no phpMyAdmin do XAMPP (aba Importar) ou rodar no console do MySQL.

CREATE DATABASE IF NOT EXISTS `atividades_dia` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `atividades_dia`;

CREATE TABLE IF NOT EXISTS `atividades` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dia` date NOT NULL,
  `titulo` varchar(100) NOT NULL,
  `descricao` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_dia` (`dia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
