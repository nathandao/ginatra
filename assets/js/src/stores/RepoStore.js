import control from "control";
import RepoActions from "actions/RepoActions";

class RepoStore {

  constructor() {
    this.bindListeners({
      updatePulseData: RepoActions.updatePulseData
    });

    this.state = {
      repoPulses: {}
    };
  }

  updatePulseData(pulseData) {
    var pulses = this.state.repoPulses;
    var keys = Object.keys(pulseData);

    for (var i = 0; i < keys.length; i++) {
      pulses[keys[i]] = pulseData[keys[i]];
    }

    this.setState({ repoPulses: pulses });
  }
}

export default control.createStore(RepoStore, "RepoStore");
