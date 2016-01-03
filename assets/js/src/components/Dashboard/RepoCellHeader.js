import React from 'react';
import moment from 'moment';

class RepoCellHeader extends React.Component {
  render() {
    let overviewData = this.props.overview.overviewData;
    let lastCommitInfo = overviewData.last_commit_info;
    let lastCommitDate = moment(lastCommitInfo.date).format('DD.MM.YY hh:mm');

    return (
      <section>
        <div className="col-fourth">{ overviewData.commits_count } commits</div>
        <div className="col-fourth">{ overviewData.additions } additions</div>
        <div className="col-fourth">{ overviewData.deletions } deletions</div>
        <div className="col-fourth">{ overviewData.lines } lines</div>
        <div className="col-full">
          Last commit on { lastCommitDate } by { lastCommitInfo.author }: { lastCommitInfo.subject }
        </div>
      </section>
    );
  }
}

export default RepoCellHeader;
