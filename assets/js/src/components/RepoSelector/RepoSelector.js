import React from 'react';
import connectToStores from 'alt/utils/connectToStores';

import SectionContainer from 'components/Utils/SectionContainer';
import RepoButton from 'components/RepoSelector/RepoButton';
import RepoStore from 'stores/RepoStore';

class RepoSelector extends React.Component {
  static getStores() {
    return [RepoStore];
  }

  static getPropsFromStores() {
    return RepoStore.getState();
  }

  render() {
    let repoButtonList = [];
    this.props.repos.map((repo) => {
      repoButtonList.push(
        <RepoButton repo={ repo } key={ repo.id }/>
      );
    });

    return (
      <SectionContainer>
        { repoButtonList }
      </SectionContainer>
    );
  }
}

export default connectToStores(RepoSelector);
