import React from "react";
import connectToStores from "alt/utils/connectToStores";

import DashboardStore from "stores/DashboardStore";
import RepoSelectButton from "components/RepoSelector/RepoSelectButton";

@connectToStores
class RepoSelector extends React.Component {

  static getStores() {
    return [ DashboardStore ];
  }

  static getPropsFromStores() {
    return DashboardStore.getState();
  }

  repoSelectButtons = () => {
    var visibleRepos = this.props.visibleRepos,
        repos = this.props.repos;

    var buttons = Object.keys(repos).map((repoId) => {
      return (
        <RepoSelectButton isActive={ visibleRepos.indexOf(repoId) > -1 }
                          name={ repos[repoId]["name"] }
                          repoId={ repoId }
                          key={ repoId } />
      );
    });

    return buttons;
  }

  render() {
    return (
      <div>
        <h1>RepoSelector</h1>
        <section>{ this.repoSelectButtons() }</section>
      </div>
    );
  }
}

export default RepoSelector;
