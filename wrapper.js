/*
 * *.js wrapper to `.sh` scripts.
 * Needed because only *JavaScript actions* support `post` jobs.
 * https://docs.github.com/en/free-pro-team@latest/actions/creating-actions/metadata-syntax-for-github-actions#post
 */

const fs = require('fs');
const os = require('os');
const { execFileSync } = require('child_process');
const path = require('path');
const isPost = !!process.env['STATE_isPost'];

if (!isPost) {
  fs.appendFileSync(process.env.GITHUB_STATE, `isPost=true${os.EOL}`, {
    encoding: 'utf8'
  });
}

const script = path.join(__dirname, isPost ? 'unmake.sh' : 'make.sh');
execFileSync(script, { stdio: 'inherit' });
