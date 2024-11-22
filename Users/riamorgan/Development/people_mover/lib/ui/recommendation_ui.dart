# Setting up Git for the Flutter project
# Navigate to the project directory and initialize Git
cd /Users/riamorgan/Development/people_mover
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/branson0011/FlutterPeopleMover.git
git branch -M main
git push -u origin main

# Creating a new feature branch for the recommendation engine
git checkout -b feature/recommendation-engine
