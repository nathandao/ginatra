import React from 'react';

import Navigation from 'components/Navigation/Navigation';

class App extends React.Component {
  render() {
    return (
      <div className="wrapper">
        <Navigation />
        { this.props.children }
      </div>
    );
  }
}

export default App;
