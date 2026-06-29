/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

export default function App() {
  const systemState = {
    service: "Dendrite Matrix Homeserver",
    client_compatibility: ["Element X", "Element Web"],
    architecture: {
      deployment: "Render (Docker Monolith)",
      primary_database: "Supabase (PostgreSQL) - Required by Dendrite",
      secondary_database: "Firebase (Optional Auxiliary Storage)"
    },
    instructions: [
      "1. Push this repository to GitHub.",
      "2. Go to Render.com -> New -> Web Service -> Connect GitHub repo.",
      "3. Render detects 'render.yaml' and builds the Docker image.",
      "4. Set 'SUPABASE_DB_URL' in Render to your Postgres connection string.",
      "5. Use the provided Render URL in Element X."
    ]
  };

  return (
    <pre style={{ 
      margin: 0, 
      padding: '2rem', 
      backgroundColor: '#000', 
      color: '#00ff00', 
      fontFamily: 'monospace',
      minHeight: '100vh',
      whiteSpace: 'pre-wrap',
      wordBreak: 'break-word'
    }}>
      {JSON.stringify(systemState, null, 2)}
    </pre>
  );
}
