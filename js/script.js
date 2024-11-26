// Função para permitir o movimento do cartão
function allowDrop(ev) {
    ev.preventDefault();
}

// Função para arrastar o cartão
function drag(ev) {
    ev.dataTransfer.setData("task_id", ev.target.id);
}

// Função para soltar o cartão em uma nova coluna
function drop(ev) {
    ev.preventDefault();
    var data = ev.dataTransfer.getData("task_id");
    var card = document.getElementById(data);
    var columnId = ev.target.id;

    // Atualizar o status da tarefa no Flask
    var taskId = card.getAttribute("data-id");
    var newStatus = columnId.replace("-", " ").toUpperCase();

    // Enviar o novo status via AJAX
    fetch('/update_task', {
        method: 'POST',
        body: new URLSearchParams({
            'task_id': taskId,
            'status': newStatus
        })
    })
    .then(response => response.json())
    .then(data => {
        console.log(data.message); // Sucesso
    })
    .catch(error => console.error('Error:', error));

    // Adicionar o cartão à nova coluna
    document.getElementById(columnId).appendChild(card);
}