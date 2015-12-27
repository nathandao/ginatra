require('../../css/main.css');

import React from 'react';
import ReactDOM from 'react-dom';
import { Router } from 'react-router';
import routes from 'routes';
import createHistory from 'history/lib/createBrowserHistory';

import DashboardServices from 'services/DashboardServices';

DashboardServices.getRepoList();
const history = createHistory();
ReactDOM.render(
  <Router routes={ routes } history={ history } />,
  document.getElementById('wrapper')
);
