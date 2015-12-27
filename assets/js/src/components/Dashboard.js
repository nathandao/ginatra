import React from 'react';

import RepoSelector from 'components/RepoSelector/RepoSelector';

class Dashboard extends React.Component {
  render() {
    return <RepoSelector repos={ this.props.repos } />;
  }
}

export default Dashboard;
