import React from 'react';
import { Router, Route } from 'react-router';

import App from 'components/App';

const routes = (
  <Router>
    <Route path="/" component={App} />
  </Router>
);

export default routes;
