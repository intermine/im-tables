# Developing

A guide to those thinking of developing the tables application and components.
This includes instructions on setting up a development environment, running the
tests, best practices and release procedure.

## Development Environment

The application is a standard JS client side application developed in a node.js
dev environment. So the first step is to install node and npm (preferably using
a node environment manager such as nvm). We currently use nvm running node
0.10.x. Dependencies are managed with npm, obviously.

Install dependencies (and run an initial build):

```sh
npm install
```

Start a development server, which builds (and rebuilds the test indices) and
serves them to the world (and runs the tests):

```sh
npm start
```

To use the test indices you will need a data server running the intermine-demo
application at port 8080 on your machine - you can get this by running the
`testmodel/setup.sh` script in the `intermine/intermine` repo.

