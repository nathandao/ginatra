import React from 'react';
import { Router, Route, IndexRoute } from 'react-router';

import App from 'App';
import Home from 'pages/Home';
import Selector from 'pages/Selector';

const routes = (
  <Router>
    <Route path="/" component={ App }>
      <IndexRoute component={ Home }/>
      <Route path="/selector" component={ Selector }/>
    </Route>
  </Router>
);

export default routes;
