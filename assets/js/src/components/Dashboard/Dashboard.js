import React from "react";
import connectToStores from "alt/utils/connectToStores";

import DashboardStore from "stores/DashboardStore";

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

  render() {
    return (
      <div>
        <h1>Dashboard</h1>
        <section>
          <div className="col-third"></div>
          <div className="col-third"></div>
          <div className="col-third"></div>
          <div className="col-third"></div>
          <div className="col-third"></div>
          <div className="col-third"></div>
          <div className="col-third"></div>
          <div className="col-third"></div>
          <div className="col-third"></div>
          <div className="col-third"></div>
          <div className="col-third"></div>
          <div className="col-third"></div>
        </section>
      </div>
    );
  }
}

export default Dashboard;
