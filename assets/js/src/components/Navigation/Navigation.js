import React from 'react';
import { Link } from 'react-router';

import SectionContainer from 'components/Utils/SectionContainer';

class Navigation extends React.Component {
  navItems() {
    let index = 0;
    let navLinks = [
      { path: '/', text: 'Dashboard' },
      { path: '/selector', text: 'Repo Selector' },
    ];
    return navLinks.map((navLink) => {
      index++;
      return (
        <li className="nav-item" key={ 'nav-item-' + index }>
          <Link to={ navLink.path }>{ navLink.text }</Link>
        </li>
      );
    });
  }

  render() {
    return (
      <SectionContainer>
        <ul className="nav-main">
          { this.navItems() }
        </ul>
      </SectionContainer>
    );
  }
}

export default Navigation;
