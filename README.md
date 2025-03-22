# Transaction Tracker: 
SwiftUI app that allows you to record intuitevely your financial transactions and store them locally. 
It lets you chat with an AI assistant to ask questions and get insights in an interactive way. 

Example below

## Description
This project is a SwiftUI app based on a simple RAG system that integrates:
- **Realm** for local data persistence, with personalized filtering 
- A **chat interface** for interacting with a Mistral model via asynchronous network requests.
- **Receipt and general financial data recognition** with a VLM. The model infers the name, the date and category for each transaction. Possibility of refining the recognition with user interaction.
- **Manual filtering** You can also review your expenses by choosing filters.



The user can enter queries about their financial transactions. The assistant can instruct the app to perform database queries (filtering, summing, etc.) and then provide a final response.


## Screenshots

<div style="display: flex; gap: 10px;">
  <img width="300" alt="Screenshot 2025-03-22 at 14 27 58" src="https://github.com/user-attachments/assets/f34da560-11fa-4728-9ea3-43391ac41086" />
  <img width="300" alt="Screenshot 2025-03-22 at 14 28 16" src="https://github.com/user-attachments/assets/6c6201e9-2c79-4565-bff8-ce6bd3db015a" />
  <img width="300" alt="Screenshot 2025-03-22 at 14 32 59" src="https://github.com/user-attachments/assets/98c8080d-a005-4e60-b3f9-66f6b09a371f" />
  <img width="300" alt="Screenshot 2025-03-22 at 14 48 55" src="https://github.com/user-attachments/assets/94563dc7-2468-4059-86f2-8c07cc365f9f" />
  <img width="300" alt="Screenshot 2025-03-22 at 15 06 54" src="https://github.com/user-attachments/assets/1fc611c0-7eb3-4768-a9e5-e2102c68a01c" />
</div>



## Todo
- Add category management
- more robust filtering output : provide more examples in prompt
- add location tag + filter + map of all transactions
- consider cloud based storage
- add 3/5 previous messages to context window for the user question
- improve UX of list of transactions
