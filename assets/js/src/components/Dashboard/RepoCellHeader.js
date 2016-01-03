import React from 'react';
import moment from 'moment';

class RepoCellHeader extends React.Component {
  render() {
    let overviewData = this.props.overview.overviewData;
    let lastCommitInfo = overviewData.last_commit_info;
    let lastCommitDate = moment(lastCommitInfo.date).format('DD.MM hh:mm');
    return (
      <div className="col-full">
        <table className="col-full">
          <tr>
            <td>{ overviewData.commits } commits</td>
            <td>{ overviewData.additions } additions</td>
            <td>{ overviewData.deletions } deletions</td>
            <td>{ overviewData.lines } lines</td>
          </tr>
        </table>
        <div className="col-full">
          Last commit on { lastCommitDate } by { lastCommitInfo.author }: { lastCommitInfo.subject }
        </div>
      </div>
    );
  }
}

export default RepoCellHeader;
