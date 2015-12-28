import React from 'react';

import RepoActions from 'actions/RepoActions';

require('./RepoButton.css');

class RepoButton extends React.Component {
  switchVisibility = () => {
    RepoActions.switchRepoVisibility(this.props.repo.id);
  }

  render() {
    let inlineStyle = {
      border: `5px solid ${ this.props.repo.color }`,
    };
    let className = 'col-third repo-button';
    if (!this.props.repo.visible) {
      className = className + ' inactive';
    } else {
      inlineStyle.backgroundColor = this.props.repo.color;
    }

    return (
      <span className={ className } onClick={ this.switchVisibility } style={ inlineStyle }>
        { this.props.repo.name }
      </span>
    );
  }
}

export default RepoButton;
