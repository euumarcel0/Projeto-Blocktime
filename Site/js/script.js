const apiKey = "9df29b3b6e0f7e056e94e157132c3b33"; // Sua chave de API
const apiToken = "ATTAa0df9fb6ed3a7423df4d2777e0c487a0fe10623f085619d304a6ab396abe67e537276987"; // Seu token
const boardId = "CXQSGuD9"; // ID do seu quadro Trello

async function fetchTrelloData() {
    try {
        // Obter listas no quadro
        const listsResponse = await fetch(
            `https://api.trello.com/1/boards/${boardId}/lists?key=${apiKey}&token=${apiToken}`
        );
        const lists = await listsResponse.json();

        // Renderizar listas e cartões
        const kanban = document.getElementById("kanban");
        for (const list of lists) {
            // Obter cartões em cada lista
            const cardsResponse = await fetch(
                `https://api.trello.com/1/lists/${list.id}/cards?key=${apiKey}&token=${apiToken}`
            );
            const cards = await cardsResponse.json();

            // Criar estrutura HTML para a lista
            const listElement = document.createElement("div");
            listElement.className = "list";
            listElement.innerHTML = `<h3>${list.name}</h3>`;

            // Adicionar cartões à lista
            cards.forEach((card) => {
                const cardElement = document.createElement("div");
                cardElement.className = "card";
                cardElement.textContent = card.name;
                listElement.appendChild(cardElement);
            });

            kanban.appendChild(listElement);
        }
    } catch (error) {
        console.error("Erro ao carregar dados do Trello:", error);
    }
}

fetchTrelloData();