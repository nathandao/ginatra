import React from 'react';

import RepoButton from 'components/RepoSelector/RepoButton';

class RepoSelector extends React.Component {
  repoButtonList() {
    let repoBtnList = [];
    this.props.repos.map((repo) => {
      repoBtnList.push(
        <RepoButton repo={ repo } key={ repo.id }/>
      );
    });
    return repoBtnList;
  }

  render() {
    return (
      <section>
        { this.repoButtonList() }
      </section>
    );
  }
}

export default RepoSelector;
