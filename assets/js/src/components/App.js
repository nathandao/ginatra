import React from "react";
import { Link } from "react-router";

import DashboardService from "services/DashboardService";

class App extends React.Component {
  componentDidMount() {
    DashboardService.getRepos();
  }

  render() {
    return(
      <div>
        <h1><Link to="/">Ginatra</Link></h1>
        <Link to="reposelector" className="button">Select Repos</Link>
        { this.props.children }
      </div>
    );
  }
}

export default App;
