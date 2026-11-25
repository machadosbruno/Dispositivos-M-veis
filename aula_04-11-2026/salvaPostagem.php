<?php
// Recebe uma foto e uma descrição (POST multipart: "foto" e "txt").
// Guarda a foto em uploads/ e registra texto e caminho na tabela postagens.
// Chamado pelo app fotos_textos.
$txt = $_POST['txt'] ?? '';
$foto = $_FILES['foto'] ?? null;

if ($txt === '' || !$foto || $foto['error'] !== UPLOAD_ERR_OK) {
    echo "Erro -> foto ou texto nao recebido";
    exit;
}

$extensao = strtolower(pathinfo($foto['name'], PATHINFO_EXTENSION));
if (!in_array($extensao, ['jpg', 'jpeg', 'png'])) {
    echo "Erro -> formato invalido";
    exit;
}

$nome = uniqid() . '.' . $extensao;
$caminho = 'uploads/' . $nome;
move_uploaded_file($foto['tmp_name'], $caminho);

$dsn = 'mysql:dbname=bancoBruno;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare("INSERT INTO `postagens` (`id`, `texto`, `caminho`) VALUES (NULL, :texto, :caminho)");
$resultado = $sth->execute(['texto' => $txt, 'caminho' => $caminho]);

if($resultado) {
    echo "Postagem salva! id=" . $dbh->lastInsertId();
} else {
    echo "Erro -> nao foi possivel salvar";
}
?>
