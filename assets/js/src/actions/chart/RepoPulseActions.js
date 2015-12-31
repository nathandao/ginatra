import control from 'control';

class RepoPulseActions {
  constructor() {
    this.generateActions(
      'loadRepoPulse',
      'requestRepoPulseStart',
      'requestRepoPulseError'
    );
  }
}

export default control.createActions(RepoPulseActions);
