import React from 'react';

class TodayOverview extends React.Component {
  render() {
    return (
      <section>
        <div className="col-half">
          <h1>{ this.props.commitsCount }</h1>
          <h2>Commits</h2>
        </div>
        <div className="col-half">
          <h3>{ this.props.additions } +</h3>
          <h3>{ this.props.deletions} -</h3>
        </div>
      </section>
    );
  }
}

export default TodayOverview;
