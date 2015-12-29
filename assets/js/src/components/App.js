import React from 'react';
import { Link } from 'react-router';

class App extends React.Component {
  render() {
    return (
      <div>
        <h1><Link to="/">Ginatra</Link></h1>
        <Link to="repo-selector">Repo Selector</Link>
        { this.props.children }
      </div>
    );
  }
}

export default App;
