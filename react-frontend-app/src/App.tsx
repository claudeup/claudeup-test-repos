// ABOUTME: Main application component for the React frontend
// ABOUTME: Demonstrates a minimal React app for team workflow testing

import { UserList } from './components/UserList';

export function App() {
  return (
    <div className="app">
      <header>
        <h1>React Frontend App</h1>
      </header>
      <main>
        <UserList />
      </main>
    </div>
  );
}
