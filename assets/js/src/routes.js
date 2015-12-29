import React from 'react';
import { Router, Route } from 'react-router';

import App from 'components/App';
import RepoSelector from 'components/RepoSelector/RepoSelector';
import Dashboard from 'components/Dashboard';

const routes = (
  <Router>
    <Route path="/" component={ App }>
      <Dashboard/>
      <Route path="repo-selector" component={ RepoSelector }/>
    </Route>
  </Router>
);

export default routes;
