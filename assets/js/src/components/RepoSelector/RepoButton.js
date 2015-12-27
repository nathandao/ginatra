import React from 'react';

import RepoActions from 'actions/RepoActions';

class RepoButton extends React.Component {
  switchVisibility = () => {
    RepoActions.switchRepoVisibility(this.props.repo.id);
  }

  render() {
    let className = 'col-third repo-button';
    if (!this.props.repo.visible) {
      className = className + ' inactive';
    }
    return (
      <span className={ className } onClick={ this.switchVisibility }>
        { this.props.repo.name }
      </span>
    );
  }
}

export default RepoButton;
