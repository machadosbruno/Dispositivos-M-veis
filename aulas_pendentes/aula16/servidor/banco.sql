CREATE DATABASE IF NOT EXISTS aula16;
USE aula16;

-- perfil: 'produtor', 'vendedor' ou 'gerente'
CREATE TABLE IF NOT EXISTS usuarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  senha VARCHAR(255) NOT NULL,
  perfil VARCHAR(10) NOT NULL
);

-- percentual de comissão atual do sistema (uma linha só)
CREATE TABLE IF NOT EXISTS config (
  id INT PRIMARY KEY,
  comissao DECIMAL(5,2) NOT NULL
);
INSERT IGNORE INTO config (id, comissao) VALUES (1, 10.00);

CREATE TABLE IF NOT EXISTS producoes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  produtor_id INT NOT NULL,
  quantidade INT NOT NULL,
  estoque INT NOT NULL,
  valor_unitario DECIMAL(10,2) NOT NULL
);

-- a comissão fica gravada em cada venda: mudar o percentual só vale para novas vendas
CREATE TABLE IF NOT EXISTS vendas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  producao_id INT NOT NULL,
  vendedor_id INT NOT NULL,
  quantidade INT NOT NULL,
  valor_total DECIMAL(10,2) NOT NULL,
  comissao_percentual DECIMAL(5,2) NOT NULL,
  valor_comissao DECIMAL(10,2) NOT NULL,
  data DATETIME NOT NULL
);

-- O gerente é criado rodando uma vez: php criar_gerente.php
