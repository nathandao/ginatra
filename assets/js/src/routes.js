import React from "react";
import { Router, Route, IndexRoute } from "react-router";

import Dashboard from "components/Dashboard/Dashboard";
import RepoSelector from "components/RepoSelector/RepoSelector";

import App from "components/App";

const routes = (
  <Router>
    <Route path="/" component={ App }>
      <IndexRoute component={ Dashboard } />

      <Route path="reposelector" component={ RepoSelector }/>
    </Route>
  </Router>
);

export default routes;
