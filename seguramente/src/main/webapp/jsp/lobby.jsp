<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.util.Random" %>

<%
    // Conexão com o Banco de Dados
    String url = "jdbc:mysql://localhost:3306/segura";
    String user = "root"; // Substituir pelo usuário real do MySQL
    String password = "!5xne5Qui8900"; // Substituir pela senha real do MySQL
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    // Criando um PIN aleatório para o lobby
    Random rand = new Random();
    int pinLobby = 1000 + rand.nextInt(9000); // Gera um PIN entre 1000 e 9999

    // Obtendo o ID do quiz da URL
    String idJogo = request.getParameter("id");
    if (idJogo == null) idJogo = "0"; // Tratamento para evitar valores null

    String tituloQuiz = "Quiz Desconhecido";
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, user, password);
        stmt = conn.createStatement();

        // Buscar o nome do quiz
        String query = "SELECT Nome FROM Jogo WHERE ID_Jogo = " + idJogo;
        rs = stmt.executeQuery(query);
        if (rs.next()) {
            tituloQuiz = rs.getString("Nome");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="pt-PT">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lobby do Quiz - <%= tituloQuiz %></title>
    <link rel="stylesheet" href="html/css/lobby.css">
    
    <!-- Importação da biblioteca QRCode.js -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
</head>
<body>

    <!-- Cabeçalho fixo -->
    <header>
        <a href="dashboard.jsp" class="site-title">SeguraMente</a>
    </header>

    <!-- 🔔 Alerta personalizado -->
    <div id="custom-alert" class="custom-alert">Aguarde mais jogadores para iniciar o quiz!</div>

    <!-- Container principal -->
    <div class="container">
        <h1><%= tituloQuiz %></h1>
        
        <!-- Seção do PIN e QR Code -->
        <div class="pin-qrcode-container">
            <div class="pin-box">
                <span>PIN:</span>
                <div id="pin-display"><%= pinLobby %></div>
            </div>
            <div id="qrcode"></div> <!-- O código QR será gerado aqui -->
        </div>

        <!-- Botão de iniciar quiz -->
        <button class="start-button" onclick="startQuiz()">Iniciar Quiz</button>

        <!-- Lista de jogadores -->
        <h3>Jogadores no Lobby</h3>
        <div class="players-container" id="players-container">
            <!-- Lista dinâmica de jogadores será adicionada aqui -->
        </div>
    </div>

	<script>
	    let players = []; // Lista de jogadores conectados
	
	    // Definição correta das variáveis JavaScript
	    const pinLobby = "<%= pinLobby %>"; 
	    const idJogo = "<%= idJogo %>"; 
	
	    // Criamos a URL do lobby para ser compartilhada via QR Code
	    const lobbyLink = `${window.location.origin}/jsp/lobby.jsp?id=${idJogo}&pin=${pinLobby}`;
	
	    function getNicknameFromUrl() {
	        const params = new URLSearchParams(window.location.search);
	        return params.get("nickname") || "Jogador Anônimo";
	    }
	
	    function addPlayer(nickname) {
	        if (!players.includes(nickname)) {
	            players.push(nickname);
	            updatePlayersList();
	        }
	    }
	
	    function updatePlayersList() {
	        const playersContainer = document.getElementById("players-container");
	        playersContainer.innerHTML = ""; 
	
	        players.forEach(player => {
	            let playerBox = document.createElement("div");
	            playerBox.classList.add("player-box");
	            playerBox.textContent = player;
	            playersContainer.appendChild(playerBox);
	        });
	    }
	
	    function startQuiz() {
	        if (players.length > 1) {
	            const quizUrl = "quizz.jsp?id=" + encodeURIComponent(idJogo) + "&pin=" + encodeURIComponent(pinLobby);
	            window.location.href = quizUrl;
	        } else {
	            showCustomAlert("Aguarde mais jogadores para iniciar o quiz!");
	        }
	    }
	
	    // Função para exibir o alerta customizado
	    function showCustomAlert(message) {
	        const alertBox = document.getElementById("custom-alert");
	        alertBox.textContent = message;
	        alertBox.style.display = "block";
	
	        setTimeout(() => {
	            alertBox.style.display = "none";
	        }, 3000);
	    }
	
	    // Função para gerar QR Code usando QRCode.js
	    function generateQRCode() {
	        const qrCodeDiv = document.getElementById("qrcode");
	        qrCodeDiv.innerHTML = ""; // Limpa QR Code anterior, se houver
	        new QRCode(qrCodeDiv, {
	            text: lobbyLink,
	            width: 150,
	            height: 150
	        });
	    }
	
	    // Inicializa a página
	    addPlayer(getNicknameFromUrl());
	    generateQRCode(); // Gera o QR Code ao carregar a página
	</script>


</body>
</html>
