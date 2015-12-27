let baseUrl = 'http://localhost:8080';

if (process.env.NODE_ENV === 'production') {
  baseUrl = '/';
}

export const API_REPO_LIST = `${baseUrl}/stat/repo_list`;
export const API_CHART_REPO_PULSE = `${baseUrl}/stat/chart/timeline/commits`;
