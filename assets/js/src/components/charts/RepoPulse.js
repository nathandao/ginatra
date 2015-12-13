import React from "react";

import BaseChart from "components/charts/BaseChart";

class RepoPulse extends React.Component {

  constructor(props) {
    super(props)
  }

  _timestamps(daysAgo) {
    if (daysAgo < 4) {
      daysAgo = 4;
    }

    var timestamps = [];

    for (i = daysAgo; i >= 3; i--) {
      timestamps = timestamps.concat(i + " days ago at 0:00");
    }

    timestamps = timestamps.concat([
      "yesterday at 0:00",
      "today at 0:00",
      "today at 23:59:59"
    ]);
  }

  render() {
    return (
      <BaseChart />
    );
  }
}

export default RepoPulse;
