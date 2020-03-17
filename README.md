# Esports Fantasy
Flutter app for Esports fantasy, connected with a back-end Python API to provide live events data, and a Firebase database for users data,rosters and players status.

## Project Status
This project is currently in development. implemented features include:
- login/register using firebase auth.
- create and view your own league of legends roster.
- gain points depending on your roster real performance in games.
- buy and sell players from all 4 major leagues (LCS,LEC,LCK,LPL).
- assign & unassign players to have 5 main players (1 per role) and 2 substitutes.
- view players market and filter players or search by name.
- view your rank among all other users around the world.
- automatic live points and leaderboard updates based on matches.
- view players personal and professional details.

## Screen shots
![alt text](https://i.postimg.cc/PqCqpXBg/login-pixel-quite-black-portrait.png)
![alt text](https://i.postimg.cc/W1W31Ffm/loading-pixel-quite-black-portrait.png)
![alt text](https://i.postimg.cc/hvB459fn/roster-pixel-quite-black-portrait.png)
![alt text](https://i.postimg.cc/TPB3r8xp/market-pixel-quite-black-portrait.png)
![alt text](https://i.postimg.cc/xCHT5sjg/player-details-pixel-quite-black-portrait.png)
![alt text](https://i.postimg.cc/6QWCTC33/leaderboard-pixel-quite-black-portrait.png)

## Reflection
This is a personal project to practise using technologies like `Dart`,`Flutter`,`Providers`,`Firebase`,`RESTful API`, and `Flask`.

I got the inspiration for this app idea while watching an esports event, many sports have their own fantasy app, but not esports, their is not a single app for either smartphone nor desktop, some skeletons and old projects remains on a few websites but none of them are active, the main challenge in maintaining such an app is to provide live esports events updates, for more info about this point refer to: https://github.com/abdullaAshraf/Esports-API.

## Implementation
The app is mainly written using `Flutter` development kit with `Dart` language, state management is done using both Lifting state and `Providers` depending on the situation, the project hierarchy is split into Screens, Widgets that are used within multiple screens, Models with data classes and providers, and Services with the access to the backend API. In addition to API there is a seprate database using `Firebase cloud` to store users accounts data and rosters, along with players prices and states that can not be provided using the live API, finally `Firebase auth` is used to handle users accounts and registration.

