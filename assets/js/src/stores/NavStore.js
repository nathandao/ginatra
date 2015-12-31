import control from 'control';

import NavActions from 'actions/NavActions';

class NavStore {
  constructor() {
    this.bindActions(NavActions);
    this.state = {
      links: [
        { path: '/', text: 'Dashboard', routeName: 'home' },
        { path: '/selector', text: 'Repo Selector', routeName: 'selector' },
      ],
      activeLink: null,
    };
  }
}

export default control.createStore(NavStore, 'NavStore');
