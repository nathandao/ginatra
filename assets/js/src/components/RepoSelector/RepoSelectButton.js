import React from "react";

import RepoActions from "actions/RepoActions";

class RepoSelectButton extends React.Component {

  _onClick = (e) => {
    e.preventDefault();
    var newState = !this.props.isActive;
    RepoActions.switchVisibility(this.props.repoId, newState);
  }

  render() {
    var className = "button col-fifth";

    if (this.props.isActive) {
      className = className + " active";
    }

    return(
      <a className={ className } onClick={ this._onClick }>
        { this.props.name }
      </a>
    );
  }
}

export default RepoSelectButton;
