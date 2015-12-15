import React from "react";
import connectToStores from "alt/utils/connectToStores";

import DashboardStore from "stores/DashboardStore";
import RepoPulse from "components/charts/RepoPulse";
import RepoService from "services/RepoService";

@connectToStores
class Dashboard extends React.Component {
  static getStores() {
    return [
      DashboardStore
    ];
  }

  static getPropsFromStores() {
    return DashboardStore.getState();
  }

  componentDidMount() {
    RepoService.getPulseData(this.props.visibleRepos);
  }

  getRepoPulses = () => {
    var repoPulses = [];
    this.props.visibleRepos.map(repoId => {
      repoPulses.push(
        <div className="col-third">
          <RepoPulse type="Line" repoId={ repoId } key={ repoId } />
        </div>
      );
    });

    return repoPulses;
  }

  render() {
    return (
      <div>
        <h1>Dashboard</h1>
        <section>
          { this.getRepoPulses() }
        </section>
      </div>
    );
  }
}

export default Dashboard;
