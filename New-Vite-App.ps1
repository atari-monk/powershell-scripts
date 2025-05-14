param([string]$name)

npx create-vite@latest $name --template react-ts
cd $name
code .
npm install
npm run dev
