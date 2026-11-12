<?php
$usuarioId = $_POST['usuario_id'];
$txt = $_POST['txt'];
$foto = $_FILES['foto'] ?? null;

$caminho = null;
if ($foto && $foto['error'] === UPLOAD_ERR_OK) {
    $nome = uniqid() . '.' . pathinfo($foto['name'], PATHINFO_EXTENSION);
    $caminho = 'uploads/' . $nome;
    move_uploaded_file($foto['tmp_name'], $caminho);
}

$dsn = 'mysql:dbname=bancoBruno;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare(
    "INSERT INTO `postagens` (`id`, `usuario_id`, `texto`, `caminho`) VALUES (NULL, :usuario_id, :texto, :caminho)"
);
$resultado = $sth->execute([
    'usuario_id' => $usuarioId,
    'texto' => $txt,
    'caminho' => $caminho,
]);

if($resultado) {
    echo "Postagem salva! id=" . $dbh->lastInsertId();
} else {
    echo "Erro -> nao foi possivel salvar";
}
?>
