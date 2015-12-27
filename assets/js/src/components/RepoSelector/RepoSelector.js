import React from 'react';

import SectionContainer from 'components/Utils/SectionContainer';
import RepoButton from 'components/RepoSelector/RepoButton';

class RepoSelector extends React.Component {
  _renderRepoButtonList() {
    return this.props.repos.map((repo) => {
      return <RepoButton repo={ repo } key={ repo.id } />;
    });
  }

  render() {
    return (
      <SectionContainer>
        <h1>Repo Selector</h1>
        { this._renderRepoButtonList() }
      </SectionContainer>
    );
  }
}

export default RepoSelector;
