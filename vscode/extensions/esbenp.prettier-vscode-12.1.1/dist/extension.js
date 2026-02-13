var __create = Object.create;
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getProtoOf = Object.getPrototypeOf;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __commonJS = (cb, mod) => function __require() {
  return mod || (0, cb[__getOwnPropNames(cb)[0]])((mod = { exports: {} }).exports, mod), mod.exports;
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
  // If the importer is in node compatibility mode or this is not an ESM
  // file that has been converted to a CommonJS file using a Babel-
  // compatible transform (i.e. "__esModule" has not been set), then set
  // "default" to the CommonJS "module.exports" for node compatibility.
  isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
  mod
));

// node_modules/semver/internal/constants.js
var require_constants = __commonJS({
  "node_modules/semver/internal/constants.js"(exports, module) {
    "use strict";
    var SEMVER_SPEC_VERSION = "2.0.0";
    var MAX_LENGTH = 256;
    var MAX_SAFE_INTEGER = Number.MAX_SAFE_INTEGER || /* istanbul ignore next */
    9007199254740991;
    var MAX_SAFE_COMPONENT_LENGTH = 16;
    var MAX_SAFE_BUILD_LENGTH = MAX_LENGTH - 6;
    var RELEASE_TYPES = [
      "major",
      "premajor",
      "minor",
      "preminor",
      "patch",
      "prepatch",
      "prerelease"
    ];
    module.exports = {
      MAX_LENGTH,
      MAX_SAFE_COMPONENT_LENGTH,
      MAX_SAFE_BUILD_LENGTH,
      MAX_SAFE_INTEGER,
      RELEASE_TYPES,
      SEMVER_SPEC_VERSION,
      FLAG_INCLUDE_PRERELEASE: 1,
      FLAG_LOOSE: 2
    };
  }
});

// node_modules/semver/internal/debug.js
var require_debug = __commonJS({
  "node_modules/semver/internal/debug.js"(exports, module) {
    "use strict";
    var debug = typeof process === "object" && process.env && process.env.NODE_DEBUG && /\bsemver\b/i.test(process.env.NODE_DEBUG) ? (...args) => console.error("SEMVER", ...args) : () => {
    };
    module.exports = debug;
  }
});

// node_modules/semver/internal/re.js
var require_re = __commonJS({
  "node_modules/semver/internal/re.js"(exports, module) {
    "use strict";
    var {
      MAX_SAFE_COMPONENT_LENGTH,
      MAX_SAFE_BUILD_LENGTH,
      MAX_LENGTH
    } = require_constants();
    var debug = require_debug();
    exports = module.exports = {};
    var re = exports.re = [];
    var safeRe = exports.safeRe = [];
    var src = exports.src = [];
    var safeSrc = exports.safeSrc = [];
    var t = exports.t = {};
    var R = 0;
    var LETTERDASHNUMBER = "[a-zA-Z0-9-]";
    var safeRegexReplacements = [
      ["\\s", 1],
      ["\\d", MAX_LENGTH],
      [LETTERDASHNUMBER, MAX_SAFE_BUILD_LENGTH]
    ];
    var makeSafeRegex = (value) => {
      for (const [token, max] of safeRegexReplacements) {
        value = value.split(`${token}*`).join(`${token}{0,${max}}`).split(`${token}+`).join(`${token}{1,${max}}`);
      }
      return value;
    };
    var createToken = (name, value, isGlobal) => {
      const safe = makeSafeRegex(value);
      const index = R++;
      debug(name, index, value);
      t[name] = index;
      src[index] = value;
      safeSrc[index] = safe;
      re[index] = new RegExp(value, isGlobal ? "g" : void 0);
      safeRe[index] = new RegExp(safe, isGlobal ? "g" : void 0);
    };
    createToken("NUMERICIDENTIFIER", "0|[1-9]\\d*");
    createToken("NUMERICIDENTIFIERLOOSE", "\\d+");
    createToken("NONNUMERICIDENTIFIER", `\\d*[a-zA-Z-]${LETTERDASHNUMBER}*`);
    createToken("MAINVERSION", `(${src[t.NUMERICIDENTIFIER]})\\.(${src[t.NUMERICIDENTIFIER]})\\.(${src[t.NUMERICIDENTIFIER]})`);
    createToken("MAINVERSIONLOOSE", `(${src[t.NUMERICIDENTIFIERLOOSE]})\\.(${src[t.NUMERICIDENTIFIERLOOSE]})\\.(${src[t.NUMERICIDENTIFIERLOOSE]})`);
    createToken("PRERELEASEIDENTIFIER", `(?:${src[t.NONNUMERICIDENTIFIER]}|${src[t.NUMERICIDENTIFIER]})`);
    createToken("PRERELEASEIDENTIFIERLOOSE", `(?:${src[t.NONNUMERICIDENTIFIER]}|${src[t.NUMERICIDENTIFIERLOOSE]})`);
    createToken("PRERELEASE", `(?:-(${src[t.PRERELEASEIDENTIFIER]}(?:\\.${src[t.PRERELEASEIDENTIFIER]})*))`);
    createToken("PRERELEASELOOSE", `(?:-?(${src[t.PRERELEASEIDENTIFIERLOOSE]}(?:\\.${src[t.PRERELEASEIDENTIFIERLOOSE]})*))`);
    createToken("BUILDIDENTIFIER", `${LETTERDASHNUMBER}+`);
    createToken("BUILD", `(?:\\+(${src[t.BUILDIDENTIFIER]}(?:\\.${src[t.BUILDIDENTIFIER]})*))`);
    createToken("FULLPLAIN", `v?${src[t.MAINVERSION]}${src[t.PRERELEASE]}?${src[t.BUILD]}?`);
    createToken("FULL", `^${src[t.FULLPLAIN]}$`);
    createToken("LOOSEPLAIN", `[v=\\s]*${src[t.MAINVERSIONLOOSE]}${src[t.PRERELEASELOOSE]}?${src[t.BUILD]}?`);
    createToken("LOOSE", `^${src[t.LOOSEPLAIN]}$`);
    createToken("GTLT", "((?:<|>)?=?)");
    createToken("XRANGEIDENTIFIERLOOSE", `${src[t.NUMERICIDENTIFIERLOOSE]}|x|X|\\*`);
    createToken("XRANGEIDENTIFIER", `${src[t.NUMERICIDENTIFIER]}|x|X|\\*`);
    createToken("XRANGEPLAIN", `[v=\\s]*(${src[t.XRANGEIDENTIFIER]})(?:\\.(${src[t.XRANGEIDENTIFIER]})(?:\\.(${src[t.XRANGEIDENTIFIER]})(?:${src[t.PRERELEASE]})?${src[t.BUILD]}?)?)?`);
    createToken("XRANGEPLAINLOOSE", `[v=\\s]*(${src[t.XRANGEIDENTIFIERLOOSE]})(?:\\.(${src[t.XRANGEIDENTIFIERLOOSE]})(?:\\.(${src[t.XRANGEIDENTIFIERLOOSE]})(?:${src[t.PRERELEASELOOSE]})?${src[t.BUILD]}?)?)?`);
    createToken("XRANGE", `^${src[t.GTLT]}\\s*${src[t.XRANGEPLAIN]}$`);
    createToken("XRANGELOOSE", `^${src[t.GTLT]}\\s*${src[t.XRANGEPLAINLOOSE]}$`);
    createToken("COERCEPLAIN", `${"(^|[^\\d])(\\d{1,"}${MAX_SAFE_COMPONENT_LENGTH}})(?:\\.(\\d{1,${MAX_SAFE_COMPONENT_LENGTH}}))?(?:\\.(\\d{1,${MAX_SAFE_COMPONENT_LENGTH}}))?`);
    createToken("COERCE", `${src[t.COERCEPLAIN]}(?:$|[^\\d])`);
    createToken("COERCEFULL", src[t.COERCEPLAIN] + `(?:${src[t.PRERELEASE]})?(?:${src[t.BUILD]})?(?:$|[^\\d])`);
    createToken("COERCERTL", src[t.COERCE], true);
    createToken("COERCERTLFULL", src[t.COERCEFULL], true);
    createToken("LONETILDE", "(?:~>?)");
    createToken("TILDETRIM", `(\\s*)${src[t.LONETILDE]}\\s+`, true);
    exports.tildeTrimReplace = "$1~";
    createToken("TILDE", `^${src[t.LONETILDE]}${src[t.XRANGEPLAIN]}$`);
    createToken("TILDELOOSE", `^${src[t.LONETILDE]}${src[t.XRANGEPLAINLOOSE]}$`);
    createToken("LONECARET", "(?:\\^)");
    createToken("CARETTRIM", `(\\s*)${src[t.LONECARET]}\\s+`, true);
    exports.caretTrimReplace = "$1^";
    createToken("CARET", `^${src[t.LONECARET]}${src[t.XRANGEPLAIN]}$`);
    createToken("CARETLOOSE", `^${src[t.LONECARET]}${src[t.XRANGEPLAINLOOSE]}$`);
    createToken("COMPARATORLOOSE", `^${src[t.GTLT]}\\s*(${src[t.LOOSEPLAIN]})$|^$`);
    createToken("COMPARATOR", `^${src[t.GTLT]}\\s*(${src[t.FULLPLAIN]})$|^$`);
    createToken("COMPARATORTRIM", `(\\s*)${src[t.GTLT]}\\s*(${src[t.LOOSEPLAIN]}|${src[t.XRANGEPLAIN]})`, true);
    exports.comparatorTrimReplace = "$1$2$3";
    createToken("HYPHENRANGE", `^\\s*(${src[t.XRANGEPLAIN]})\\s+-\\s+(${src[t.XRANGEPLAIN]})\\s*$`);
    createToken("HYPHENRANGELOOSE", `^\\s*(${src[t.XRANGEPLAINLOOSE]})\\s+-\\s+(${src[t.XRANGEPLAINLOOSE]})\\s*$`);
    createToken("STAR", "(<|>)?=?\\s*\\*");
    createToken("GTE0", "^\\s*>=\\s*0\\.0\\.0\\s*$");
    createToken("GTE0PRE", "^\\s*>=\\s*0\\.0\\.0-0\\s*$");
  }
});

// node_modules/semver/internal/parse-options.js
var require_parse_options = __commonJS({
  "node_modules/semver/internal/parse-options.js"(exports, module) {
    "use strict";
    var looseOption = Object.freeze({ loose: true });
    var emptyOpts = Object.freeze({});
    var parseOptions = (options) => {
      if (!options) {
        return emptyOpts;
      }
      if (typeof options !== "object") {
        return looseOption;
      }
      return options;
    };
    module.exports = parseOptions;
  }
});

// node_modules/semver/internal/identifiers.js
var require_identifiers = __commonJS({
  "node_modules/semver/internal/identifiers.js"(exports, module) {
    "use strict";
    var numeric = /^[0-9]+$/;
    var compareIdentifiers = (a, b) => {
      if (typeof a === "number" && typeof b === "number") {
        return a === b ? 0 : a < b ? -1 : 1;
      }
      const anum = numeric.test(a);
      const bnum = numeric.test(b);
      if (anum && bnum) {
        a = +a;
        b = +b;
      }
      return a === b ? 0 : anum && !bnum ? -1 : bnum && !anum ? 1 : a < b ? -1 : 1;
    };
    var rcompareIdentifiers = (a, b) => compareIdentifiers(b, a);
    module.exports = {
      compareIdentifiers,
      rcompareIdentifiers
    };
  }
});

// node_modules/semver/classes/semver.js
var require_semver = __commonJS({
  "node_modules/semver/classes/semver.js"(exports, module) {
    "use strict";
    var debug = require_debug();
    var { MAX_LENGTH, MAX_SAFE_INTEGER } = require_constants();
    var { safeRe: re, t } = require_re();
    var parseOptions = require_parse_options();
    var { compareIdentifiers } = require_identifiers();
    var SemVer = class _SemVer {
      constructor(version, options) {
        options = parseOptions(options);
        if (version instanceof _SemVer) {
          if (version.loose === !!options.loose && version.includePrerelease === !!options.includePrerelease) {
            return version;
          } else {
            version = version.version;
          }
        } else if (typeof version !== "string") {
          throw new TypeError(`Invalid version. Must be a string. Got type "${typeof version}".`);
        }
        if (version.length > MAX_LENGTH) {
          throw new TypeError(
            `version is longer than ${MAX_LENGTH} characters`
          );
        }
        debug("SemVer", version, options);
        this.options = options;
        this.loose = !!options.loose;
        this.includePrerelease = !!options.includePrerelease;
        const m = version.trim().match(options.loose ? re[t.LOOSE] : re[t.FULL]);
        if (!m) {
          throw new TypeError(`Invalid Version: ${version}`);
        }
        this.raw = version;
        this.major = +m[1];
        this.minor = +m[2];
        this.patch = +m[3];
        if (this.major > MAX_SAFE_INTEGER || this.major < 0) {
          throw new TypeError("Invalid major version");
        }
        if (this.minor > MAX_SAFE_INTEGER || this.minor < 0) {
          throw new TypeError("Invalid minor version");
        }
        if (this.patch > MAX_SAFE_INTEGER || this.patch < 0) {
          throw new TypeError("Invalid patch version");
        }
        if (!m[4]) {
          this.prerelease = [];
        } else {
          this.prerelease = m[4].split(".").map((id) => {
            if (/^[0-9]+$/.test(id)) {
              const num = +id;
              if (num >= 0 && num < MAX_SAFE_INTEGER) {
                return num;
              }
            }
            return id;
          });
        }
        this.build = m[5] ? m[5].split(".") : [];
        this.format();
      }
      format() {
        this.version = `${this.major}.${this.minor}.${this.patch}`;
        if (this.prerelease.length) {
          this.version += `-${this.prerelease.join(".")}`;
        }
        return this.version;
      }
      toString() {
        return this.version;
      }
      compare(other) {
        debug("SemVer.compare", this.version, this.options, other);
        if (!(other instanceof _SemVer)) {
          if (typeof other === "string" && other === this.version) {
            return 0;
          }
          other = new _SemVer(other, this.options);
        }
        if (other.version === this.version) {
          return 0;
        }
        return this.compareMain(other) || this.comparePre(other);
      }
      compareMain(other) {
        if (!(other instanceof _SemVer)) {
          other = new _SemVer(other, this.options);
        }
        if (this.major < other.major) {
          return -1;
        }
        if (this.major > other.major) {
          return 1;
        }
        if (this.minor < other.minor) {
          return -1;
        }
        if (this.minor > other.minor) {
          return 1;
        }
        if (this.patch < other.patch) {
          return -1;
        }
        if (this.patch > other.patch) {
          return 1;
        }
        return 0;
      }
      comparePre(other) {
        if (!(other instanceof _SemVer)) {
          other = new _SemVer(other, this.options);
        }
        if (this.prerelease.length && !other.prerelease.length) {
          return -1;
        } else if (!this.prerelease.length && other.prerelease.length) {
          return 1;
        } else if (!this.prerelease.length && !other.prerelease.length) {
          return 0;
        }
        let i = 0;
        do {
          const a = this.prerelease[i];
          const b = other.prerelease[i];
          debug("prerelease compare", i, a, b);
          if (a === void 0 && b === void 0) {
            return 0;
          } else if (b === void 0) {
            return 1;
          } else if (a === void 0) {
            return -1;
          } else if (a === b) {
            continue;
          } else {
            return compareIdentifiers(a, b);
          }
        } while (++i);
      }
      compareBuild(other) {
        if (!(other instanceof _SemVer)) {
          other = new _SemVer(other, this.options);
        }
        let i = 0;
        do {
          const a = this.build[i];
          const b = other.build[i];
          debug("build compare", i, a, b);
          if (a === void 0 && b === void 0) {
            return 0;
          } else if (b === void 0) {
            return 1;
          } else if (a === void 0) {
            return -1;
          } else if (a === b) {
            continue;
          } else {
            return compareIdentifiers(a, b);
          }
        } while (++i);
      }
      // preminor will bump the version up to the next minor release, and immediately
      // down to pre-release. premajor and prepatch work the same way.
      inc(release, identifier, identifierBase) {
        if (release.startsWith("pre")) {
          if (!identifier && identifierBase === false) {
            throw new Error("invalid increment argument: identifier is empty");
          }
          if (identifier) {
            const match = `-${identifier}`.match(this.options.loose ? re[t.PRERELEASELOOSE] : re[t.PRERELEASE]);
            if (!match || match[1] !== identifier) {
              throw new Error(`invalid identifier: ${identifier}`);
            }
          }
        }
        switch (release) {
          case "premajor":
            this.prerelease.length = 0;
            this.patch = 0;
            this.minor = 0;
            this.major++;
            this.inc("pre", identifier, identifierBase);
            break;
          case "preminor":
            this.prerelease.length = 0;
            this.patch = 0;
            this.minor++;
            this.inc("pre", identifier, identifierBase);
            break;
          case "prepatch":
            this.prerelease.length = 0;
            this.inc("patch", identifier, identifierBase);
            this.inc("pre", identifier, identifierBase);
            break;
          // If the input is a non-prerelease version, this acts the same as
          // prepatch.
          case "prerelease":
            if (this.prerelease.length === 0) {
              this.inc("patch", identifier, identifierBase);
            }
            this.inc("pre", identifier, identifierBase);
            break;
          case "release":
            if (this.prerelease.length === 0) {
              throw new Error(`version ${this.raw} is not a prerelease`);
            }
            this.prerelease.length = 0;
            break;
          case "major":
            if (this.minor !== 0 || this.patch !== 0 || this.prerelease.length === 0) {
              this.major++;
            }
            this.minor = 0;
            this.patch = 0;
            this.prerelease = [];
            break;
          case "minor":
            if (this.patch !== 0 || this.prerelease.length === 0) {
              this.minor++;
            }
            this.patch = 0;
            this.prerelease = [];
            break;
          case "patch":
            if (this.prerelease.length === 0) {
              this.patch++;
            }
            this.prerelease = [];
            break;
          // This probably shouldn't be used publicly.
          // 1.0.0 'pre' would become 1.0.0-0 which is the wrong direction.
          case "pre": {
            const base = Number(identifierBase) ? 1 : 0;
            if (this.prerelease.length === 0) {
              this.prerelease = [base];
            } else {
              let i = this.prerelease.length;
              while (--i >= 0) {
                if (typeof this.prerelease[i] === "number") {
                  this.prerelease[i]++;
                  i = -2;
                }
              }
              if (i === -1) {
                if (identifier === this.prerelease.join(".") && identifierBase === false) {
                  throw new Error("invalid increment argument: identifier already exists");
                }
                this.prerelease.push(base);
              }
            }
            if (identifier) {
              let prerelease = [identifier, base];
              if (identifierBase === false) {
                prerelease = [identifier];
              }
              if (compareIdentifiers(this.prerelease[0], identifier) === 0) {
                if (isNaN(this.prerelease[1])) {
                  this.prerelease = prerelease;
                }
              } else {
                this.prerelease = prerelease;
              }
            }
            break;
          }
          default:
            throw new Error(`invalid increment argument: ${release}`);
        }
        this.raw = this.format();
        if (this.build.length) {
          this.raw += `+${this.build.join(".")}`;
        }
        return this;
      }
    };
    module.exports = SemVer;
  }
});

// node_modules/semver/functions/parse.js
var require_parse = __commonJS({
  "node_modules/semver/functions/parse.js"(exports, module) {
    "use strict";
    var SemVer = require_semver();
    var parse3 = (version, options, throwErrors = false) => {
      if (version instanceof SemVer) {
        return version;
      }
      try {
        return new SemVer(version, options);
      } catch (er) {
        if (!throwErrors) {
          return null;
        }
        throw er;
      }
    };
    module.exports = parse3;
  }
});

// node_modules/semver/functions/valid.js
var require_valid = __commonJS({
  "node_modules/semver/functions/valid.js"(exports, module) {
    "use strict";
    var parse3 = require_parse();
    var valid = (version, options) => {
      const v = parse3(version, options);
      return v ? v.version : null;
    };
    module.exports = valid;
  }
});

// node_modules/semver/functions/clean.js
var require_clean = __commonJS({
  "node_modules/semver/functions/clean.js"(exports, module) {
    "use strict";
    var parse3 = require_parse();
    var clean = (version, options) => {
      const s = parse3(version.trim().replace(/^[=v]+/, ""), options);
      return s ? s.version : null;
    };
    module.exports = clean;
  }
});

// node_modules/semver/functions/inc.js
var require_inc = __commonJS({
  "node_modules/semver/functions/inc.js"(exports, module) {
    "use strict";
    var SemVer = require_semver();
    var inc = (version, release, options, identifier, identifierBase) => {
      if (typeof options === "string") {
        identifierBase = identifier;
        identifier = options;
        options = void 0;
      }
      try {
        return new SemVer(
          version instanceof SemVer ? version.version : version,
          options
        ).inc(release, identifier, identifierBase).version;
      } catch (er) {
        return null;
      }
    };
    module.exports = inc;
  }
});

// node_modules/semver/functions/diff.js
var require_diff = __commonJS({
  "node_modules/semver/functions/diff.js"(exports, module) {
    "use strict";
    var parse3 = require_parse();
    var diff = (version1, version2) => {
      const v1 = parse3(version1, null, true);
      const v2 = parse3(version2, null, true);
      const comparison = v1.compare(v2);
      if (comparison === 0) {
        return null;
      }
      const v1Higher = comparison > 0;
      const highVersion = v1Higher ? v1 : v2;
      const lowVersion = v1Higher ? v2 : v1;
      const highHasPre = !!highVersion.prerelease.length;
      const lowHasPre = !!lowVersion.prerelease.length;
      if (lowHasPre && !highHasPre) {
        if (!lowVersion.patch && !lowVersion.minor) {
          return "major";
        }
        if (lowVersion.compareMain(highVersion) === 0) {
          if (lowVersion.minor && !lowVersion.patch) {
            return "minor";
          }
          return "patch";
        }
      }
      const prefix = highHasPre ? "pre" : "";
      if (v1.major !== v2.major) {
        return prefix + "major";
      }
      if (v1.minor !== v2.minor) {
        return prefix + "minor";
      }
      if (v1.patch !== v2.patch) {
        return prefix + "patch";
      }
      return "prerelease";
    };
    module.exports = diff;
  }
});

// node_modules/semver/functions/major.js
var require_major = __commonJS({
  "node_modules/semver/functions/major.js"(exports, module) {
    "use strict";
    var SemVer = require_semver();
    var major = (a, loose) => new SemVer(a, loose).major;
    module.exports = major;
  }
});

// node_modules/semver/functions/minor.js
var require_minor = __commonJS({
  "node_modules/semver/functions/minor.js"(exports, module) {
    "use strict";
    var SemVer = require_semver();
    var minor = (a, loose) => new SemVer(a, loose).minor;
    module.exports = minor;
  }
});

// node_modules/semver/functions/patch.js
var require_patch = __commonJS({
  "node_modules/semver/functions/patch.js"(exports, module) {
    "use strict";
    var SemVer = require_semver();
    var patch = (a, loose) => new SemVer(a, loose).patch;
    module.exports = patch;
  }
});

// node_modules/semver/functions/prerelease.js
var require_prerelease = __commonJS({
  "node_modules/semver/functions/prerelease.js"(exports, module) {
    "use strict";
    var parse3 = require_parse();
    var prerelease = (version, options) => {
      const parsed = parse3(version, options);
      return parsed && parsed.prerelease.length ? parsed.prerelease : null;
    };
    module.exports = prerelease;
  }
});

// node_modules/semver/functions/compare.js
var require_compare = __commonJS({
  "node_modules/semver/functions/compare.js"(exports, module) {
    "use strict";
    var SemVer = require_semver();
    var compare = (a, b, loose) => new SemVer(a, loose).compare(new SemVer(b, loose));
    module.exports = compare;
  }
});

// node_modules/semver/functions/rcompare.js
var require_rcompare = __commonJS({
  "node_modules/semver/functions/rcompare.js"(exports, module) {
    "use strict";
    var compare = require_compare();
    var rcompare = (a, b, loose) => compare(b, a, loose);
    module.exports = rcompare;
  }
});

// node_modules/semver/functions/compare-loose.js
var require_compare_loose = __commonJS({
  "node_modules/semver/functions/compare-loose.js"(exports, module) {
    "use strict";
    var compare = require_compare();
    var compareLoose = (a, b) => compare(a, b, true);
    module.exports = compareLoose;
  }
});

// node_modules/semver/functions/compare-build.js
var require_compare_build = __commonJS({
  "node_modules/semver/functions/compare-build.js"(exports, module) {
    "use strict";
    var SemVer = require_semver();
    var compareBuild = (a, b, loose) => {
      const versionA = new SemVer(a, loose);
      const versionB = new SemVer(b, loose);
      return versionA.compare(versionB) || versionA.compareBuild(versionB);
    };
    module.exports = compareBuild;
  }
});

// node_modules/semver/functions/sort.js
var require_sort = __commonJS({
  "node_modules/semver/functions/sort.js"(exports, module) {
    "use strict";
    var compareBuild = require_compare_build();
    var sort = (list, loose) => list.sort((a, b) => compareBuild(a, b, loose));
    module.exports = sort;
  }
});

// node_modules/semver/functions/rsort.js
var require_rsort = __commonJS({
  "node_modules/semver/functions/rsort.js"(exports, module) {
    "use strict";
    var compareBuild = require_compare_build();
    var rsort = (list, loose) => list.sort((a, b) => compareBuild(b, a, loose));
    module.exports = rsort;
  }
});

// node_modules/semver/functions/gt.js
var require_gt = __commonJS({
  "node_modules/semver/functions/gt.js"(exports, module) {
    "use strict";
    var compare = require_compare();
    var gt = (a, b, loose) => compare(a, b, loose) > 0;
    module.exports = gt;
  }
});

// node_modules/semver/functions/lt.js
var require_lt = __commonJS({
  "node_modules/semver/functions/lt.js"(exports, module) {
    "use strict";
    var compare = require_compare();
    var lt = (a, b, loose) => compare(a, b, loose) < 0;
    module.exports = lt;
  }
});

// node_modules/semver/functions/eq.js
var require_eq = __commonJS({
  "node_modules/semver/functions/eq.js"(exports, module) {
    "use strict";
    var compare = require_compare();
    var eq = (a, b, loose) => compare(a, b, loose) === 0;
    module.exports = eq;
  }
});

// node_modules/semver/functions/neq.js
var require_neq = __commonJS({
  "node_modules/semver/functions/neq.js"(exports, module) {
    "use strict";
    var compare = require_compare();
    var neq = (a, b, loose) => compare(a, b, loose) !== 0;
    module.exports = neq;
  }
});

// node_modules/semver/functions/gte.js
var require_gte = __commonJS({
  "node_modules/semver/functions/gte.js"(exports, module) {
    "use strict";
    var compare = require_compare();
    var gte2 = (a, b, loose) => compare(a, b, loose) >= 0;
    module.exports = gte2;
  }
});

// node_modules/semver/functions/lte.js
var require_lte = __commonJS({
  "node_modules/semver/functions/lte.js"(exports, module) {
    "use strict";
    var compare = require_compare();
    var lte = (a, b, loose) => compare(a, b, loose) <= 0;
    module.exports = lte;
  }
});

// node_modules/semver/functions/cmp.js
var require_cmp = __commonJS({
  "node_modules/semver/functions/cmp.js"(exports, module) {
    "use strict";
    var eq = require_eq();
    var neq = require_neq();
    var gt = require_gt();
    var gte2 = require_gte();
    var lt = require_lt();
    var lte = require_lte();
    var cmp = (a, op, b, loose) => {
      switch (op) {
        case "===":
          if (typeof a === "object") {
            a = a.version;
          }
          if (typeof b === "object") {
            b = b.version;
          }
          return a === b;
        case "!==":
          if (typeof a === "object") {
            a = a.version;
          }
          if (typeof b === "object") {
            b = b.version;
          }
          return a !== b;
        case "":
        case "=":
        case "==":
          return eq(a, b, loose);
        case "!=":
          return neq(a, b, loose);
        case ">":
          return gt(a, b, loose);
        case ">=":
          return gte2(a, b, loose);
        case "<":
          return lt(a, b, loose);
        case "<=":
          return lte(a, b, loose);
        default:
          throw new TypeError(`Invalid operator: ${op}`);
      }
    };
    module.exports = cmp;
  }
});

// node_modules/semver/functions/coerce.js
var require_coerce = __commonJS({
  "node_modules/semver/functions/coerce.js"(exports, module) {
    "use strict";
    var SemVer = require_semver();
    var parse3 = require_parse();
    var { safeRe: re, t } = require_re();
    var coerce = (version, options) => {
      if (version instanceof SemVer) {
        return version;
      }
      if (typeof version === "number") {
        version = String(version);
      }
      if (typeof version !== "string") {
        return null;
      }
      options = options || {};
      let match = null;
      if (!options.rtl) {
        match = version.match(options.includePrerelease ? re[t.COERCEFULL] : re[t.COERCE]);
      } else {
        const coerceRtlRegex = options.includePrerelease ? re[t.COERCERTLFULL] : re[t.COERCERTL];
        let next;
        while ((next = coerceRtlRegex.exec(version)) && (!match || match.index + match[0].length !== version.length)) {
          if (!match || next.index + next[0].length !== match.index + match[0].length) {
            match = next;
          }
          coerceRtlRegex.lastIndex = next.index + next[1].length + next[2].length;
        }
        coerceRtlRegex.lastIndex = -1;
      }
      if (match === null) {
        return null;
      }
      const major = match[2];
      const minor = match[3] || "0";
      const patch = match[4] || "0";
      const prerelease = options.includePrerelease && match[5] ? `-${match[5]}` : "";
      const build = options.includePrerelease && match[6] ? `+${match[6]}` : "";
      return parse3(`${major}.${minor}.${patch}${prerelease}${build}`, options);
    };
    module.exports = coerce;
  }
});

// node_modules/semver/internal/lrucache.js
var require_lrucache = __commonJS({
  "node_modules/semver/internal/lrucache.js"(exports, module) {
    "use strict";
    var LRUCache = class {
      constructor() {
        this.max = 1e3;
        this.map = /* @__PURE__ */ new Map();
      }
      get(key) {
        const value = this.map.get(key);
        if (value === void 0) {
          return void 0;
        } else {
          this.map.delete(key);
          this.map.set(key, value);
          return value;
        }
      }
      delete(key) {
        return this.map.delete(key);
      }
      set(key, value) {
        const deleted = this.delete(key);
        if (!deleted && value !== void 0) {
          if (this.map.size >= this.max) {
            const firstKey = this.map.keys().next().value;
            this.delete(firstKey);
          }
          this.map.set(key, value);
        }
        return this;
      }
    };
    module.exports = LRUCache;
  }
});

// node_modules/semver/classes/range.js
var require_range = __commonJS({
  "node_modules/semver/classes/range.js"(exports, module) {
    "use strict";
    var SPACE_CHARACTERS = /\s+/g;
    var Range3 = class _Range {
      constructor(range, options) {
        options = parseOptions(options);
        if (range instanceof _Range) {
          if (range.loose === !!options.loose && range.includePrerelease === !!options.includePrerelease) {
            return range;
          } else {
            return new _Range(range.raw, options);
          }
        }
        if (range instanceof Comparator) {
          this.raw = range.value;
          this.set = [[range]];
          this.formatted = void 0;
          return this;
        }
        this.options = options;
        this.loose = !!options.loose;
        this.includePrerelease = !!options.includePrerelease;
        this.raw = range.trim().replace(SPACE_CHARACTERS, " ");
        this.set = this.raw.split("||").map((r) => this.parseRange(r.trim())).filter((c) => c.length);
        if (!this.set.length) {
          throw new TypeError(`Invalid SemVer Range: ${this.raw}`);
        }
        if (this.set.length > 1) {
          const first = this.set[0];
          this.set = this.set.filter((c) => !isNullSet(c[0]));
          if (this.set.length === 0) {
            this.set = [first];
          } else if (this.set.length > 1) {
            for (const c of this.set) {
              if (c.length === 1 && isAny(c[0])) {
                this.set = [c];
                break;
              }
            }
          }
        }
        this.formatted = void 0;
      }
      get range() {
        if (this.formatted === void 0) {
          this.formatted = "";
          for (let i = 0; i < this.set.length; i++) {
            if (i > 0) {
              this.formatted += "||";
            }
            const comps = this.set[i];
            for (let k = 0; k < comps.length; k++) {
              if (k > 0) {
                this.formatted += " ";
              }
              this.formatted += comps[k].toString().trim();
            }
          }
        }
        return this.formatted;
      }
      format() {
        return this.range;
      }
      toString() {
        return this.range;
      }
      parseRange(range) {
        const memoOpts = (this.options.includePrerelease && FLAG_INCLUDE_PRERELEASE) | (this.options.loose && FLAG_LOOSE);
        const memoKey = memoOpts + ":" + range;
        const cached = cache.get(memoKey);
        if (cached) {
          return cached;
        }
        const loose = this.options.loose;
        const hr = loose ? re[t.HYPHENRANGELOOSE] : re[t.HYPHENRANGE];
        range = range.replace(hr, hyphenReplace(this.options.includePrerelease));
        debug("hyphen replace", range);
        range = range.replace(re[t.COMPARATORTRIM], comparatorTrimReplace);
        debug("comparator trim", range);
        range = range.replace(re[t.TILDETRIM], tildeTrimReplace);
        debug("tilde trim", range);
        range = range.replace(re[t.CARETTRIM], caretTrimReplace);
        debug("caret trim", range);
        let rangeList = range.split(" ").map((comp) => parseComparator(comp, this.options)).join(" ").split(/\s+/).map((comp) => replaceGTE0(comp, this.options));
        if (loose) {
          rangeList = rangeList.filter((comp) => {
            debug("loose invalid filter", comp, this.options);
            return !!comp.match(re[t.COMPARATORLOOSE]);
          });
        }
        debug("range list", rangeList);
        const rangeMap = /* @__PURE__ */ new Map();
        const comparators = rangeList.map((comp) => new Comparator(comp, this.options));
        for (const comp of comparators) {
          if (isNullSet(comp)) {
            return [comp];
          }
          rangeMap.set(comp.value, comp);
        }
        if (rangeMap.size > 1 && rangeMap.has("")) {
          rangeMap.delete("");
        }
        const result = [...rangeMap.values()];
        cache.set(memoKey, result);
        return result;
      }
      intersects(range, options) {
        if (!(range instanceof _Range)) {
          throw new TypeError("a Range is required");
        }
        return this.set.some((thisComparators) => {
          return isSatisfiable(thisComparators, options) && range.set.some((rangeComparators) => {
            return isSatisfiable(rangeComparators, options) && thisComparators.every((thisComparator) => {
              return rangeComparators.every((rangeComparator) => {
                return thisComparator.intersects(rangeComparator, options);
              });
            });
          });
        });
      }
      // if ANY of the sets match ALL of its comparators, then pass
      test(version) {
        if (!version) {
          return false;
        }
        if (typeof version === "string") {
          try {
            version = new SemVer(version, this.options);
          } catch (er) {
            return false;
          }
        }
        for (let i = 0; i < this.set.length; i++) {
          if (testSet(this.set[i], version, this.options)) {
            return true;
          }
        }
        return false;
      }
    };
    module.exports = Range3;
    var LRU = require_lrucache();
    var cache = new LRU();
    var parseOptions = require_parse_options();
    var Comparator = require_comparator();
    var debug = require_debug();
    var SemVer = require_semver();
    var {
      safeRe: re,
      t,
      comparatorTrimReplace,
      tildeTrimReplace,
      caretTrimReplace
    } = require_re();
    var { FLAG_INCLUDE_PRERELEASE, FLAG_LOOSE } = require_constants();
    var isNullSet = (c) => c.value === "<0.0.0-0";
    var isAny = (c) => c.value === "";
    var isSatisfiable = (comparators, options) => {
      let result = true;
      const remainingComparators = comparators.slice();
      let testComparator = remainingComparators.pop();
      while (result && remainingComparators.length) {
        result = remainingComparators.every((otherComparator) => {
          return testComparator.intersects(otherComparator, options);
        });
        testComparator = remainingComparators.pop();
      }
      return result;
    };
    var parseComparator = (comp, options) => {
      comp = comp.replace(re[t.BUILD], "");
      debug("comp", comp, options);
      comp = replaceCarets(comp, options);
      debug("caret", comp);
      comp = replaceTildes(comp, options);
      debug("tildes", comp);
      comp = replaceXRanges(comp, options);
      debug("xrange", comp);
      comp = replaceStars(comp, options);
      debug("stars", comp);
      return comp;
    };
    var isX = (id) => !id || id.toLowerCase() === "x" || id === "*";
    var replaceTildes = (comp, options) => {
      return comp.trim().split(/\s+/).map((c) => replaceTilde(c, options)).join(" ");
    };
    var replaceTilde = (comp, options) => {
      const r = options.loose ? re[t.TILDELOOSE] : re[t.TILDE];
      return comp.replace(r, (_, M, m, p, pr) => {
        debug("tilde", comp, _, M, m, p, pr);
        let ret;
        if (isX(M)) {
          ret = "";
        } else if (isX(m)) {
          ret = `>=${M}.0.0 <${+M + 1}.0.0-0`;
        } else if (isX(p)) {
          ret = `>=${M}.${m}.0 <${M}.${+m + 1}.0-0`;
        } else if (pr) {
          debug("replaceTilde pr", pr);
          ret = `>=${M}.${m}.${p}-${pr} <${M}.${+m + 1}.0-0`;
        } else {
          ret = `>=${M}.${m}.${p} <${M}.${+m + 1}.0-0`;
        }
        debug("tilde return", ret);
        return ret;
      });
    };
    var replaceCarets = (comp, options) => {
      return comp.trim().split(/\s+/).map((c) => replaceCaret(c, options)).join(" ");
    };
    var replaceCaret = (comp, options) => {
      debug("caret", comp, options);
      const r = options.loose ? re[t.CARETLOOSE] : re[t.CARET];
      const z = options.includePrerelease ? "-0" : "";
      return comp.replace(r, (_, M, m, p, pr) => {
        debug("caret", comp, _, M, m, p, pr);
        let ret;
        if (isX(M)) {
          ret = "";
        } else if (isX(m)) {
          ret = `>=${M}.0.0${z} <${+M + 1}.0.0-0`;
        } else if (isX(p)) {
          if (M === "0") {
            ret = `>=${M}.${m}.0${z} <${M}.${+m + 1}.0-0`;
          } else {
            ret = `>=${M}.${m}.0${z} <${+M + 1}.0.0-0`;
          }
        } else if (pr) {
          debug("replaceCaret pr", pr);
          if (M === "0") {
            if (m === "0") {
              ret = `>=${M}.${m}.${p}-${pr} <${M}.${m}.${+p + 1}-0`;
            } else {
              ret = `>=${M}.${m}.${p}-${pr} <${M}.${+m + 1}.0-0`;
            }
          } else {
            ret = `>=${M}.${m}.${p}-${pr} <${+M + 1}.0.0-0`;
          }
        } else {
          debug("no pr");
          if (M === "0") {
            if (m === "0") {
              ret = `>=${M}.${m}.${p}${z} <${M}.${m}.${+p + 1}-0`;
            } else {
              ret = `>=${M}.${m}.${p}${z} <${M}.${+m + 1}.0-0`;
            }
          } else {
            ret = `>=${M}.${m}.${p} <${+M + 1}.0.0-0`;
          }
        }
        debug("caret return", ret);
        return ret;
      });
    };
    var replaceXRanges = (comp, options) => {
      debug("replaceXRanges", comp, options);
      return comp.split(/\s+/).map((c) => replaceXRange(c, options)).join(" ");
    };
    var replaceXRange = (comp, options) => {
      comp = comp.trim();
      const r = options.loose ? re[t.XRANGELOOSE] : re[t.XRANGE];
      return comp.replace(r, (ret, gtlt, M, m, p, pr) => {
        debug("xRange", comp, ret, gtlt, M, m, p, pr);
        const xM = isX(M);
        const xm = xM || isX(m);
        const xp = xm || isX(p);
        const anyX = xp;
        if (gtlt === "=" && anyX) {
          gtlt = "";
        }
        pr = options.includePrerelease ? "-0" : "";
        if (xM) {
          if (gtlt === ">" || gtlt === "<") {
            ret = "<0.0.0-0";
          } else {
            ret = "*";
          }
        } else if (gtlt && anyX) {
          if (xm) {
            m = 0;
          }
          p = 0;
          if (gtlt === ">") {
            gtlt = ">=";
            if (xm) {
              M = +M + 1;
              m = 0;
              p = 0;
            } else {
              m = +m + 1;
              p = 0;
            }
          } else if (gtlt === "<=") {
            gtlt = "<";
            if (xm) {
              M = +M + 1;
            } else {
              m = +m + 1;
            }
          }
          if (gtlt === "<") {
            pr = "-0";
          }
          ret = `${gtlt + M}.${m}.${p}${pr}`;
        } else if (xm) {
          ret = `>=${M}.0.0${pr} <${+M + 1}.0.0-0`;
        } else if (xp) {
          ret = `>=${M}.${m}.0${pr} <${M}.${+m + 1}.0-0`;
        }
        debug("xRange return", ret);
        return ret;
      });
    };
    var replaceStars = (comp, options) => {
      debug("replaceStars", comp, options);
      return comp.trim().replace(re[t.STAR], "");
    };
    var replaceGTE0 = (comp, options) => {
      debug("replaceGTE0", comp, options);
      return comp.trim().replace(re[options.includePrerelease ? t.GTE0PRE : t.GTE0], "");
    };
    var hyphenReplace = (incPr) => ($0, from, fM, fm, fp, fpr, fb, to, tM, tm, tp, tpr) => {
      if (isX(fM)) {
        from = "";
      } else if (isX(fm)) {
        from = `>=${fM}.0.0${incPr ? "-0" : ""}`;
      } else if (isX(fp)) {
        from = `>=${fM}.${fm}.0${incPr ? "-0" : ""}`;
      } else if (fpr) {
        from = `>=${from}`;
      } else {
        from = `>=${from}${incPr ? "-0" : ""}`;
      }
      if (isX(tM)) {
        to = "";
      } else if (isX(tm)) {
        to = `<${+tM + 1}.0.0-0`;
      } else if (isX(tp)) {
        to = `<${tM}.${+tm + 1}.0-0`;
      } else if (tpr) {
        to = `<=${tM}.${tm}.${tp}-${tpr}`;
      } else if (incPr) {
        to = `<${tM}.${tm}.${+tp + 1}-0`;
      } else {
        to = `<=${to}`;
      }
      return `${from} ${to}`.trim();
    };
    var testSet = (set, version, options) => {
      for (let i = 0; i < set.length; i++) {
        if (!set[i].test(version)) {
          return false;
        }
      }
      if (version.prerelease.length && !options.includePrerelease) {
        for (let i = 0; i < set.length; i++) {
          debug(set[i].semver);
          if (set[i].semver === Comparator.ANY) {
            continue;
          }
          if (set[i].semver.prerelease.length > 0) {
            const allowed = set[i].semver;
            if (allowed.major === version.major && allowed.minor === version.minor && allowed.patch === version.patch) {
              return true;
            }
          }
        }
        return false;
      }
      return true;
    };
  }
});

// node_modules/semver/classes/comparator.js
var require_comparator = __commonJS({
  "node_modules/semver/classes/comparator.js"(exports, module) {
    "use strict";
    var ANY = /* @__PURE__ */ Symbol("SemVer ANY");
    var Comparator = class _Comparator {
      static get ANY() {
        return ANY;
      }
      constructor(comp, options) {
        options = parseOptions(options);
        if (comp instanceof _Comparator) {
          if (comp.loose === !!options.loose) {
            return comp;
          } else {
            comp = comp.value;
          }
        }
        comp = comp.trim().split(/\s+/).join(" ");
        debug("comparator", comp, options);
        this.options = options;
        this.loose = !!options.loose;
        this.parse(comp);
        if (this.semver === ANY) {
          this.value = "";
        } else {
          this.value = this.operator + this.semver.version;
        }
        debug("comp", this);
      }
      parse(comp) {
        const r = this.options.loose ? re[t.COMPARATORLOOSE] : re[t.COMPARATOR];
        const m = comp.match(r);
        if (!m) {
          throw new TypeError(`Invalid comparator: ${comp}`);
        }
        this.operator = m[1] !== void 0 ? m[1] : "";
        if (this.operator === "=") {
          this.operator = "";
        }
        if (!m[2]) {
          this.semver = ANY;
        } else {
          this.semver = new SemVer(m[2], this.options.loose);
        }
      }
      toString() {
        return this.value;
      }
      test(version) {
        debug("Comparator.test", version, this.options.loose);
        if (this.semver === ANY || version === ANY) {
          return true;
        }
        if (typeof version === "string") {
          try {
            version = new SemVer(version, this.options);
          } catch (er) {
            return false;
          }
        }
        return cmp(version, this.operator, this.semver, this.options);
      }
      intersects(comp, options) {
        if (!(comp instanceof _Comparator)) {
          throw new TypeError("a Comparator is required");
        }
        if (this.operator === "") {
          if (this.value === "") {
            return true;
          }
          return new Range3(comp.value, options).test(this.value);
        } else if (comp.operator === "") {
          if (comp.value === "") {
            return true;
          }
          return new Range3(this.value, options).test(comp.semver);
        }
        options = parseOptions(options);
        if (options.includePrerelease && (this.value === "<0.0.0-0" || comp.value === "<0.0.0-0")) {
          return false;
        }
        if (!options.includePrerelease && (this.value.startsWith("<0.0.0") || comp.value.startsWith("<0.0.0"))) {
          return false;
        }
        if (this.operator.startsWith(">") && comp.operator.startsWith(">")) {
          return true;
        }
        if (this.operator.startsWith("<") && comp.operator.startsWith("<")) {
          return true;
        }
        if (this.semver.version === comp.semver.version && this.operator.includes("=") && comp.operator.includes("=")) {
          return true;
        }
        if (cmp(this.semver, "<", comp.semver, options) && this.operator.startsWith(">") && comp.operator.startsWith("<")) {
          return true;
        }
        if (cmp(this.semver, ">", comp.semver, options) && this.operator.startsWith("<") && comp.operator.startsWith(">")) {
          return true;
        }
        return false;
      }
    };
    module.exports = Comparator;
    var parseOptions = require_parse_options();
    var { safeRe: re, t } = require_re();
    var cmp = require_cmp();
    var debug = require_debug();
    var SemVer = require_semver();
    var Range3 = require_range();
  }
});

// node_modules/semver/functions/satisfies.js
var require_satisfies = __commonJS({
  "node_modules/semver/functions/satisfies.js"(exports, module) {
    "use strict";
    var Range3 = require_range();
    var satisfies = (version, range, options) => {
      try {
        range = new Range3(range, options);
      } catch (er) {
        return false;
      }
      return range.test(version);
    };
    module.exports = satisfies;
  }
});

// node_modules/semver/ranges/to-comparators.js
var require_to_comparators = __commonJS({
  "node_modules/semver/ranges/to-comparators.js"(exports, module) {
    "use strict";
    var Range3 = require_range();
    var toComparators = (range, options) => new Range3(range, options).set.map((comp) => comp.map((c) => c.value).join(" ").trim().split(" "));
    module.exports = toComparators;
  }
});

// node_modules/semver/ranges/max-satisfying.js
var require_max_satisfying = __commonJS({
  "node_modules/semver/ranges/max-satisfying.js"(exports, module) {
    "use strict";
    var SemVer = require_semver();
    var Range3 = require_range();
    var maxSatisfying = (versions, range, options) => {
      let max = null;
      let maxSV = null;
      let rangeObj = null;
      try {
        rangeObj = new Range3(range, options);
      } catch (er) {
        return null;
      }
      versions.forEach((v) => {
        if (rangeObj.test(v)) {
          if (!max || maxSV.compare(v) === -1) {
            max = v;
            maxSV = new SemVer(max, options);
          }
        }
      });
      return max;
    };
    module.exports = maxSatisfying;
  }
});

// node_modules/semver/ranges/min-satisfying.js
var require_min_satisfying = __commonJS({
  "node_modules/semver/ranges/min-satisfying.js"(exports, module) {
    "use strict";
    var SemVer = require_semver();
    var Range3 = require_range();
    var minSatisfying = (versions, range, options) => {
      let min = null;
      let minSV = null;
      let rangeObj = null;
      try {
        rangeObj = new Range3(range, options);
      } catch (er) {
        return null;
      }
      versions.forEach((v) => {
        if (rangeObj.test(v)) {
          if (!min || minSV.compare(v) === 1) {
            min = v;
            minSV = new SemVer(min, options);
          }
        }
      });
      return min;
    };
    module.exports = minSatisfying;
  }
});

// node_modules/semver/ranges/min-version.js
var require_min_version = __commonJS({
  "node_modules/semver/ranges/min-version.js"(exports, module) {
    "use strict";
    var SemVer = require_semver();
    var Range3 = require_range();
    var gt = require_gt();
    var minVersion = (range, loose) => {
      range = new Range3(range, loose);
      let minver = new SemVer("0.0.0");
      if (range.test(minver)) {
        return minver;
      }
      minver = new SemVer("0.0.0-0");
      if (range.test(minver)) {
        return minver;
      }
      minver = null;
      for (let i = 0; i < range.set.length; ++i) {
        const comparators = range.set[i];
        let setMin = null;
        comparators.forEach((comparator) => {
          const compver = new SemVer(comparator.semver.version);
          switch (comparator.operator) {
            case ">":
              if (compver.prerelease.length === 0) {
                compver.patch++;
              } else {
                compver.prerelease.push(0);
              }
              compver.raw = compver.format();
            /* fallthrough */
            case "":
            case ">=":
              if (!setMin || gt(compver, setMin)) {
                setMin = compver;
              }
              break;
            case "<":
            case "<=":
              break;
            /* istanbul ignore next */
            default:
              throw new Error(`Unexpected operation: ${comparator.operator}`);
          }
        });
        if (setMin && (!minver || gt(minver, setMin))) {
          minver = setMin;
        }
      }
      if (minver && range.test(minver)) {
        return minver;
      }
      return null;
    };
    module.exports = minVersion;
  }
});

// node_modules/semver/ranges/valid.js
var require_valid2 = __commonJS({
  "node_modules/semver/ranges/valid.js"(exports, module) {
    "use strict";
    var Range3 = require_range();
    var validRange = (range, options) => {
      try {
        return new Range3(range, options).range || "*";
      } catch (er) {
        return null;
      }
    };
    module.exports = validRange;
  }
});

// node_modules/semver/ranges/outside.js
var require_outside = __commonJS({
  "node_modules/semver/ranges/outside.js"(exports, module) {
    "use strict";
    var SemVer = require_semver();
    var Comparator = require_comparator();
    var { ANY } = Comparator;
    var Range3 = require_range();
    var satisfies = require_satisfies();
    var gt = require_gt();
    var lt = require_lt();
    var lte = require_lte();
    var gte2 = require_gte();
    var outside = (version, range, hilo, options) => {
      version = new SemVer(version, options);
      range = new Range3(range, options);
      let gtfn, ltefn, ltfn, comp, ecomp;
      switch (hilo) {
        case ">":
          gtfn = gt;
          ltefn = lte;
          ltfn = lt;
          comp = ">";
          ecomp = ">=";
          break;
        case "<":
          gtfn = lt;
          ltefn = gte2;
          ltfn = gt;
          comp = "<";
          ecomp = "<=";
          break;
        default:
          throw new TypeError('Must provide a hilo val of "<" or ">"');
      }
      if (satisfies(version, range, options)) {
        return false;
      }
      for (let i = 0; i < range.set.length; ++i) {
        const comparators = range.set[i];
        let high = null;
        let low = null;
        comparators.forEach((comparator) => {
          if (comparator.semver === ANY) {
            comparator = new Comparator(">=0.0.0");
          }
          high = high || comparator;
          low = low || comparator;
          if (gtfn(comparator.semver, high.semver, options)) {
            high = comparator;
          } else if (ltfn(comparator.semver, low.semver, options)) {
            low = comparator;
          }
        });
        if (high.operator === comp || high.operator === ecomp) {
          return false;
        }
        if ((!low.operator || low.operator === comp) && ltefn(version, low.semver)) {
          return false;
        } else if (low.operator === ecomp && ltfn(version, low.semver)) {
          return false;
        }
      }
      return true;
    };
    module.exports = outside;
  }
});

// node_modules/semver/ranges/gtr.js
var require_gtr = __commonJS({
  "node_modules/semver/ranges/gtr.js"(exports, module) {
    "use strict";
    var outside = require_outside();
    var gtr = (version, range, options) => outside(version, range, ">", options);
    module.exports = gtr;
  }
});

// node_modules/semver/ranges/ltr.js
var require_ltr = __commonJS({
  "node_modules/semver/ranges/ltr.js"(exports, module) {
    "use strict";
    var outside = require_outside();
    var ltr = (version, range, options) => outside(version, range, "<", options);
    module.exports = ltr;
  }
});

// node_modules/semver/ranges/intersects.js
var require_intersects = __commonJS({
  "node_modules/semver/ranges/intersects.js"(exports, module) {
    "use strict";
    var Range3 = require_range();
    var intersects = (r1, r2, options) => {
      r1 = new Range3(r1, options);
      r2 = new Range3(r2, options);
      return r1.intersects(r2, options);
    };
    module.exports = intersects;
  }
});

// node_modules/semver/ranges/simplify.js
var require_simplify = __commonJS({
  "node_modules/semver/ranges/simplify.js"(exports, module) {
    "use strict";
    var satisfies = require_satisfies();
    var compare = require_compare();
    module.exports = (versions, range, options) => {
      const set = [];
      let first = null;
      let prev = null;
      const v = versions.sort((a, b) => compare(a, b, options));
      for (const version of v) {
        const included = satisfies(version, range, options);
        if (included) {
          prev = version;
          if (!first) {
            first = version;
          }
        } else {
          if (prev) {
            set.push([first, prev]);
          }
          prev = null;
          first = null;
        }
      }
      if (first) {
        set.push([first, null]);
      }
      const ranges = [];
      for (const [min, max] of set) {
        if (min === max) {
          ranges.push(min);
        } else if (!max && min === v[0]) {
          ranges.push("*");
        } else if (!max) {
          ranges.push(`>=${min}`);
        } else if (min === v[0]) {
          ranges.push(`<=${max}`);
        } else {
          ranges.push(`${min} - ${max}`);
        }
      }
      const simplified = ranges.join(" || ");
      const original = typeof range.raw === "string" ? range.raw : String(range);
      return simplified.length < original.length ? simplified : range;
    };
  }
});

// node_modules/semver/ranges/subset.js
var require_subset = __commonJS({
  "node_modules/semver/ranges/subset.js"(exports, module) {
    "use strict";
    var Range3 = require_range();
    var Comparator = require_comparator();
    var { ANY } = Comparator;
    var satisfies = require_satisfies();
    var compare = require_compare();
    var subset = (sub, dom, options = {}) => {
      if (sub === dom) {
        return true;
      }
      sub = new Range3(sub, options);
      dom = new Range3(dom, options);
      let sawNonNull = false;
      OUTER: for (const simpleSub of sub.set) {
        for (const simpleDom of dom.set) {
          const isSub = simpleSubset(simpleSub, simpleDom, options);
          sawNonNull = sawNonNull || isSub !== null;
          if (isSub) {
            continue OUTER;
          }
        }
        if (sawNonNull) {
          return false;
        }
      }
      return true;
    };
    var minimumVersionWithPreRelease = [new Comparator(">=0.0.0-0")];
    var minimumVersion = [new Comparator(">=0.0.0")];
    var simpleSubset = (sub, dom, options) => {
      if (sub === dom) {
        return true;
      }
      if (sub.length === 1 && sub[0].semver === ANY) {
        if (dom.length === 1 && dom[0].semver === ANY) {
          return true;
        } else if (options.includePrerelease) {
          sub = minimumVersionWithPreRelease;
        } else {
          sub = minimumVersion;
        }
      }
      if (dom.length === 1 && dom[0].semver === ANY) {
        if (options.includePrerelease) {
          return true;
        } else {
          dom = minimumVersion;
        }
      }
      const eqSet = /* @__PURE__ */ new Set();
      let gt, lt;
      for (const c of sub) {
        if (c.operator === ">" || c.operator === ">=") {
          gt = higherGT(gt, c, options);
        } else if (c.operator === "<" || c.operator === "<=") {
          lt = lowerLT(lt, c, options);
        } else {
          eqSet.add(c.semver);
        }
      }
      if (eqSet.size > 1) {
        return null;
      }
      let gtltComp;
      if (gt && lt) {
        gtltComp = compare(gt.semver, lt.semver, options);
        if (gtltComp > 0) {
          return null;
        } else if (gtltComp === 0 && (gt.operator !== ">=" || lt.operator !== "<=")) {
          return null;
        }
      }
      for (const eq of eqSet) {
        if (gt && !satisfies(eq, String(gt), options)) {
          return null;
        }
        if (lt && !satisfies(eq, String(lt), options)) {
          return null;
        }
        for (const c of dom) {
          if (!satisfies(eq, String(c), options)) {
            return false;
          }
        }
        return true;
      }
      let higher, lower;
      let hasDomLT, hasDomGT;
      let needDomLTPre = lt && !options.includePrerelease && lt.semver.prerelease.length ? lt.semver : false;
      let needDomGTPre = gt && !options.includePrerelease && gt.semver.prerelease.length ? gt.semver : false;
      if (needDomLTPre && needDomLTPre.prerelease.length === 1 && lt.operator === "<" && needDomLTPre.prerelease[0] === 0) {
        needDomLTPre = false;
      }
      for (const c of dom) {
        hasDomGT = hasDomGT || c.operator === ">" || c.operator === ">=";
        hasDomLT = hasDomLT || c.operator === "<" || c.operator === "<=";
        if (gt) {
          if (needDomGTPre) {
            if (c.semver.prerelease && c.semver.prerelease.length && c.semver.major === needDomGTPre.major && c.semver.minor === needDomGTPre.minor && c.semver.patch === needDomGTPre.patch) {
              needDomGTPre = false;
            }
          }
          if (c.operator === ">" || c.operator === ">=") {
            higher = higherGT(gt, c, options);
            if (higher === c && higher !== gt) {
              return false;
            }
          } else if (gt.operator === ">=" && !satisfies(gt.semver, String(c), options)) {
            return false;
          }
        }
        if (lt) {
          if (needDomLTPre) {
            if (c.semver.prerelease && c.semver.prerelease.length && c.semver.major === needDomLTPre.major && c.semver.minor === needDomLTPre.minor && c.semver.patch === needDomLTPre.patch) {
              needDomLTPre = false;
            }
          }
          if (c.operator === "<" || c.operator === "<=") {
            lower = lowerLT(lt, c, options);
            if (lower === c && lower !== lt) {
              return false;
            }
          } else if (lt.operator === "<=" && !satisfies(lt.semver, String(c), options)) {
            return false;
          }
        }
        if (!c.operator && (lt || gt) && gtltComp !== 0) {
          return false;
        }
      }
      if (gt && hasDomLT && !lt && gtltComp !== 0) {
        return false;
      }
      if (lt && hasDomGT && !gt && gtltComp !== 0) {
        return false;
      }
      if (needDomGTPre || needDomLTPre) {
        return false;
      }
      return true;
    };
    var higherGT = (a, b, options) => {
      if (!a) {
        return b;
      }
      const comp = compare(a.semver, b.semver, options);
      return comp > 0 ? a : comp < 0 ? b : b.operator === ">" && a.operator === ">=" ? b : a;
    };
    var lowerLT = (a, b, options) => {
      if (!a) {
        return b;
      }
      const comp = compare(a.semver, b.semver, options);
      return comp < 0 ? a : comp > 0 ? b : b.operator === "<" && a.operator === "<=" ? b : a;
    };
    module.exports = subset;
  }
});

// node_modules/semver/index.js
var require_semver2 = __commonJS({
  "node_modules/semver/index.js"(exports, module) {
    "use strict";
    var internalRe = require_re();
    var constants = require_constants();
    var SemVer = require_semver();
    var identifiers = require_identifiers();
    var parse3 = require_parse();
    var valid = require_valid();
    var clean = require_clean();
    var inc = require_inc();
    var diff = require_diff();
    var major = require_major();
    var minor = require_minor();
    var patch = require_patch();
    var prerelease = require_prerelease();
    var compare = require_compare();
    var rcompare = require_rcompare();
    var compareLoose = require_compare_loose();
    var compareBuild = require_compare_build();
    var sort = require_sort();
    var rsort = require_rsort();
    var gt = require_gt();
    var lt = require_lt();
    var eq = require_eq();
    var neq = require_neq();
    var gte2 = require_gte();
    var lte = require_lte();
    var cmp = require_cmp();
    var coerce = require_coerce();
    var Comparator = require_comparator();
    var Range3 = require_range();
    var satisfies = require_satisfies();
    var toComparators = require_to_comparators();
    var maxSatisfying = require_max_satisfying();
    var minSatisfying = require_min_satisfying();
    var minVersion = require_min_version();
    var validRange = require_valid2();
    var outside = require_outside();
    var gtr = require_gtr();
    var ltr = require_ltr();
    var intersects = require_intersects();
    var simplifyRange = require_simplify();
    var subset = require_subset();
    module.exports = {
      parse: parse3,
      valid,
      clean,
      inc,
      diff,
      major,
      minor,
      patch,
      prerelease,
      compare,
      rcompare,
      compareLoose,
      compareBuild,
      sort,
      rsort,
      gt,
      lt,
      eq,
      neq,
      gte: gte2,
      lte,
      cmp,
      coerce,
      Comparator,
      Range: Range3,
      satisfies,
      toComparators,
      maxSatisfying,
      minSatisfying,
      minVersion,
      validRange,
      outside,
      gtr,
      ltr,
      intersects,
      simplifyRange,
      subset,
      SemVer,
      re: internalRe.re,
      src: internalRe.src,
      tokens: internalRe.t,
      SEMVER_SPEC_VERSION: constants.SEMVER_SPEC_VERSION,
      RELEASE_TYPES: constants.RELEASE_TYPES,
      compareIdentifiers: identifiers.compareIdentifiers,
      rcompareIdentifiers: identifiers.rcompareIdentifiers
    };
  }
});

// src/extension.ts
import { commands as commands2, workspace as workspace5 } from "vscode";

// src/commands.ts
import { window } from "vscode";
var createConfigFile = (templateService) => async () => {
  const folderResult = await window.showOpenDialog({
    canSelectFiles: false,
    canSelectFolders: true,
    canSelectMany: false
  });
  if (folderResult && folderResult.length === 1) {
    const folderUri = folderResult[0];
    await templateService.writeConfigFile(folderUri);
  }
};

// src/LoggingService.ts
import { window as window2 } from "vscode";
var LoggingService = class {
  outputChannel = window2.createOutputChannel("Prettier");
  logLevel = "INFO";
  setOutputLevel(logLevel) {
    this.logLevel = logLevel;
  }
  /**
   * Append messages to the output channel and format it with a title
   *
   * @param message The message to append to the output channel
   */
  logDebug(message, data) {
    if (this.logLevel === "NONE" || this.logLevel === "INFO" || this.logLevel === "WARN" || this.logLevel === "ERROR") {
      return;
    }
    this.logMessage(message, "DEBUG");
    if (data) {
      this.logObject(data);
    }
  }
  /**
   * Append messages to the output channel and format it with a title
   *
   * @param message The message to append to the output channel
   */
  logInfo(message, data) {
    if (this.logLevel === "NONE" || this.logLevel === "WARN" || this.logLevel === "ERROR") {
      return;
    }
    this.logMessage(message, "INFO");
    if (data) {
      this.logObject(data);
    }
  }
  /**
   * Append messages to the output channel and format it with a title
   *
   * @param message The message to append to the output channel
   */
  logWarning(message, data) {
    if (this.logLevel === "NONE" || this.logLevel === "ERROR") {
      return;
    }
    this.logMessage(message, "WARN");
    if (data) {
      this.logObject(data);
    }
  }
  logError(message, error) {
    if (this.logLevel === "NONE") {
      return;
    }
    this.logMessage(message, "ERROR");
    if (typeof error === "string") {
      this.outputChannel.appendLine(error);
    } else if (error instanceof Error) {
      if (error?.message) {
        this.logMessage(error.message, "ERROR");
      }
      if (error?.stack) {
        this.outputChannel.appendLine(error.stack);
      }
    } else if (error) {
      this.logObject(error);
    }
  }
  show() {
    this.outputChannel.show();
  }
  logObject(data) {
    const message = JSON.stringify(data, null, 2);
    this.outputChannel.appendLine(message);
  }
  /**
   * Append messages to the output channel and format it with a title
   *
   * @param message The message to append to the output channel
   */
  logMessage(message, logLevel) {
    const title = (/* @__PURE__ */ new Date()).toLocaleTimeString();
    this.outputChannel.appendLine(`["${logLevel}" - ${title}] ${message}`);
  }
};

// src/ModuleResolverNode.ts
var semver = __toESM(require_semver2(), 1);
import * as fs2 from "fs";
import * as path6 from "path";
import { commands, Uri as Uri2, window as window3, workspace as workspace2 } from "vscode";

// src/utils/global-node-paths.ts
import * as path from "path";

// src/utils/exec.ts
import { spawn } from "child_process";
async function execAsync(command, args, options = {}) {
  const { timeout = 1e4, ...spawnOptions } = options;
  return new Promise((resolve3, reject) => {
    const proc = spawn(command, args, {
      shell: process.platform === "win32",
      ...spawnOptions
    });
    let stdout = "";
    let stderr = "";
    let killed = false;
    const timeoutId = setTimeout(() => {
      killed = true;
      proc.kill("SIGTERM");
      reject(new Error(`Command timed out after ${timeout}ms: ${command}`));
    }, timeout);
    proc.stdout?.on("data", (data) => {
      stdout += data;
    });
    proc.stderr?.on("data", (data) => {
      stderr += data;
    });
    proc.on("close", (code) => {
      clearTimeout(timeoutId);
      if (killed) return;
      if (code === 0) {
        resolve3(stdout.trim());
      } else {
        reject(
          new Error(
            stderr.trim() || `Command failed with exit code ${code}: ${command}`
          )
        );
      }
    });
    proc.on("error", (error) => {
      clearTimeout(timeoutId);
      if (!killed) {
        reject(error);
      }
    });
  });
}

// src/utils/global-node-paths.ts
function isWindows() {
  return process.platform === "win32";
}
var SHELL_TIMEOUT = 5e3;
async function resolveGlobalNodePath(tracer) {
  const npmCommand = isWindows() ? "npm.cmd" : "npm";
  try {
    const prefix = await execAsync(npmCommand, ["config", "get", "prefix"], {
      timeout: SHELL_TIMEOUT
    });
    if (tracer) {
      tracer(`'npm config get prefix' value is: ${prefix}`);
    }
    if (prefix.length > 0) {
      if (isWindows()) {
        return path.join(prefix, "node_modules");
      } else {
        return path.join(prefix, "lib", "node_modules");
      }
    }
    return void 0;
  } catch (error) {
    if (tracer) {
      tracer(`'npm config get prefix' failed: ${error}`);
    }
    return void 0;
  }
}
async function resolveGlobalYarnPath(tracer) {
  const yarnCommand = isWindows() ? "yarn.cmd" : "yarn";
  try {
    const stdout = await execAsync(yarnCommand, ["global", "dir", "--json"], {
      timeout: SHELL_TIMEOUT
    });
    const lines = stdout.trim().split(/\r?\n/);
    for (const line of lines) {
      try {
        const yarn = JSON.parse(line);
        if (yarn.type === "log") {
          return path.join(yarn.data, "node_modules");
        }
      } catch {
      }
    }
    return void 0;
  } catch (error) {
    if (tracer) {
      tracer(`'yarn global dir' failed: ${error}`);
    }
    return void 0;
  }
}
async function resolveGlobalPnpmPath(tracer) {
  const pnpmCommand = isWindows() ? "pnpm.cmd" : "pnpm";
  try {
    const pnpmPath = await execAsync(pnpmCommand, ["root", "-g"], {
      timeout: SHELL_TIMEOUT
    });
    if (tracer) {
      tracer(`'pnpm root -g' value is: ${pnpmPath}`);
    }
    return pnpmPath;
  } catch (error) {
    if (tracer) {
      tracer(`'pnpm root -g' failed: ${error}`);
    }
    return void 0;
  }
}

// src/utils/find-up.ts
import * as fs from "fs";
import * as path2 from "path";
var FIND_UP_STOP = /* @__PURE__ */ Symbol("findUpStop");
async function findUp(matcher, options) {
  let dir = path2.resolve(options.cwd);
  const root = path2.parse(dir).root;
  while (true) {
    const result = await matcher(dir);
    if (result === FIND_UP_STOP) {
      return void 0;
    }
    if (result !== void 0) {
      return options.type === "directory" ? dir : result;
    }
    if (dir === root) {
      return void 0;
    }
    dir = path2.dirname(dir);
  }
}
async function pathExists(filePath) {
  try {
    await fs.promises.access(filePath);
    return true;
  } catch {
    return false;
  }
}

// src/message.ts
var OUTDATED_PRETTIER_VERSION_MESSAGE = "Your project is configured to use an outdated version of prettier that cannot be used by this extension. Upgrade to the latest version of prettier.";
var INVALID_PRETTIER_PATH_MESSAGE = "`prettierPath` option does not reference a valid instance of Prettier. Please ensure you are passing a path to the prettier module, not the binary. Falling back to bundled version of prettier.";
var FAILED_TO_LOAD_MODULE_MESSAGE = "Failed to load module. If you have prettier or plugins referenced in package.json, ensure you have run `npm install`";
var INVALID_PRETTIER_CONFIG = "Invalid prettier configuration file detected. See log for details.";
var RESTART_TO_ENABLE = "To enable or disable prettier after changing the `enable` setting, you must restart VS Code.";
var USING_BUNDLED_PRETTIER = "Using bundled version of prettier.";
var EXTENSION_DISABLED = "Extension is disabled. No formatters will be registered. To enable, change the `prettier.enable` to `true` and restart VS Code.";
var UNTRUSTED_WORKSPACE_USING_BUNDLED_PRETTIER = "This workspace is not trusted. Using the bundled version of prettier.";

// src/utils/workspace.ts
import * as os from "os";
import * as path3 from "path";
import { Uri, workspace } from "vscode";
function getWorkspaceRelativePath(filePath, pathToResolve) {
  if (process.platform === "darwin" && pathToResolve.indexOf("~") === 0 && os.homedir()) {
    return pathToResolve.replace(/^~(?=$|\/|\\)/, os.homedir());
  }
  if (workspace.workspaceFolders) {
    const folder = workspace.getWorkspaceFolder(Uri.file(filePath));
    return folder ? path3.isAbsolute(pathToResolve) ? pathToResolve : path3.join(folder.uri.fsPath, pathToResolve) : void 0;
  }
}
function getWorkspaceConfig(scope) {
  const config = workspace.getConfiguration(
    "prettier",
    scope
  );
  if (!workspace.isTrusted) {
    const newConfig = {
      ...config,
      prettierPath: void 0,
      configPath: void 0,
      ignorePath: ".prettierignore",
      documentSelectors: [],
      useEditorConfig: false,
      withNodeModules: false,
      resolveGlobalModules: false
    };
    return newConfig;
  }
  return config;
}

// src/PrettierDynamicInstance.ts
import * as path5 from "path";
import { pathToFileURL as pathToFileURL2 } from "url";

// src/utils/resolve-module-entry.ts
import { createRequire } from "module";
import { pathToFileURL } from "url";
import * as path4 from "path";
function resolveModuleEntry(fromDirectory, moduleName) {
  const fakeFile = path4.join(fromDirectory, "noop.js");
  const require2 = createRequire(pathToFileURL(fakeFile).href);
  return require2.resolve(moduleName);
}

// src/PrettierDynamicInstance.ts
var PrettierDynamicInstance = class PrettierDynamicInstance2 {
  constructor(modulePath) {
    this.modulePath = modulePath;
  }
  version = null;
  prettierModule;
  async import() {
    let entryPath;
    const ext = path5.extname(this.modulePath).toLowerCase();
    if (ext === ".js" || ext === ".cjs" || ext === ".mjs") {
      entryPath = this.modulePath;
    } else {
      entryPath = resolveModuleEntry(
        this.modulePath,
        path5.basename(this.modulePath)
      );
    }
    const moduleUrl = pathToFileURL2(entryPath).href;
    const imported = await import(moduleUrl);
    this.prettierModule = imported.default?.version ? imported.default : imported;
    this.version = this.prettierModule?.version ?? null;
    if (this.version == null) {
      throw new Error(`Failed to load Prettier instance: ${this.modulePath}`);
    }
    return this.version;
  }
  async format(source, options) {
    if (!this.prettierModule) {
      await this.import();
    }
    return this.prettierModule.format(source, options);
  }
  async getFileInfo(filePath, fileInfoOptions) {
    if (!this.prettierModule) {
      await this.import();
    }
    return this.prettierModule.getFileInfo(filePath, fileInfoOptions);
  }
  async getSupportInfo({
    plugins
  }) {
    if (!this.prettierModule) {
      await this.import();
    }
    return this.prettierModule.getSupportInfo({ plugins });
  }
  async clearConfigCache() {
    if (!this.prettierModule) {
      await this.import();
    }
    return this.prettierModule.clearConfigCache();
  }
  async resolveConfigFile(filePath) {
    if (!this.prettierModule) {
      await this.import();
    }
    return this.prettierModule.resolveConfigFile(filePath);
  }
  async resolveConfig(fileName, options) {
    if (!this.prettierModule) {
      await this.import();
    }
    return this.prettierModule.resolveConfig(fileName, options);
  }
};

// src/ModuleResolverNode.ts
var minPrettierVersion = "1.13.0";
var prettierModule;
async function getBundledPrettier() {
  if (!prettierModule) {
    const imported = await import("prettier");
    prettierModule = imported.default?.version ? imported.default : imported;
  }
  return prettierModule;
}
var globalPathCache = /* @__PURE__ */ new Map();
async function globalPathGet(packageManager) {
  if (globalPathCache.has(packageManager)) {
    return globalPathCache.get(packageManager);
  }
  let resolvePromise;
  switch (packageManager) {
    case "npm":
      resolvePromise = resolveGlobalNodePath();
      break;
    case "yarn":
      resolvePromise = resolveGlobalYarnPath();
      break;
    case "pnpm":
      resolvePromise = resolveGlobalPnpmPath();
      break;
    default:
      resolvePromise = Promise.resolve(void 0);
  }
  globalPathCache.set(packageManager, resolvePromise);
  return resolvePromise;
}
var ModuleResolver = class {
  constructor(loggingService) {
    this.loggingService = loggingService;
  }
  path2Module = /* @__PURE__ */ new Map();
  async getGlobalPrettierInstance() {
    return getBundledPrettier();
  }
  async getPrettierInstance(fileName) {
    if (!workspace2.isTrusted) {
      this.loggingService.logDebug(UNTRUSTED_WORKSPACE_USING_BUNDLED_PRETTIER);
      return getBundledPrettier();
    }
    const { prettierPath, resolveGlobalModules } = getWorkspaceConfig(
      Uri2.file(fileName)
    );
    let modulePath;
    try {
      modulePath = prettierPath ? await this.getModuleFromPrettierPath(fileName, prettierPath) : await this.findPrettierModule(fileName);
    } catch (error) {
      let msg = `Unable to find prettier module`;
      if (error instanceof Error) {
        msg += `: ${error.message}`;
      }
      this.loggingService.logError(msg);
    }
    if (!modulePath && resolveGlobalModules) {
      modulePath = await this.findGlobalModule("prettier");
    }
    if (!modulePath) {
      this.loggingService.logDebug(USING_BUNDLED_PRETTIER);
      return getBundledPrettier();
    }
    const isValidVersion = await this.isValidVersion(modulePath);
    if (!isValidVersion) {
      return void 0;
    }
    let prettierInstance = this.path2Module.get(modulePath);
    if (prettierInstance) {
      return prettierInstance;
    }
    prettierInstance = new PrettierDynamicInstance(modulePath);
    try {
      await prettierInstance.import();
    } catch (error) {
      this.loggingService.logError(
        `${FAILED_TO_LOAD_MODULE_MESSAGE}: ${modulePath}`,
        error
      );
      return void 0;
    }
    this.path2Module.set(modulePath, prettierInstance);
    return prettierInstance;
  }
  async getModuleFromPrettierPath(fileName, prettierPath) {
    const absolutePrettierPath = path6.isAbsolute(prettierPath) ? prettierPath : path6.join(
      workspace2.getWorkspaceFolder(Uri2.file(fileName))?.uri.fsPath ?? "",
      prettierPath
    );
    if (await pathExists(absolutePrettierPath)) {
      return absolutePrettierPath;
    }
    this.loggingService.logError(INVALID_PRETTIER_PATH_MESSAGE);
    return void 0;
  }
  async getResolvedIgnorePath(fileName, ignorePath) {
    const resolvedPath = getWorkspaceRelativePath(fileName, ignorePath);
    if (resolvedPath && await pathExists(resolvedPath)) {
      return resolvedPath;
    }
    const foundPath = await findUp(
      async (dir) => {
        const ignoreFilePath = path6.join(dir, ignorePath);
        if (await pathExists(ignoreFilePath)) {
          return ignoreFilePath;
        }
        if (await pathExists(path6.join(dir, ".do-not-use-prettier-vscode-root"))) {
          return FIND_UP_STOP;
        }
        return void 0;
      },
      { cwd: path6.dirname(fileName) }
    );
    if (foundPath) {
      return foundPath;
    }
    this.loggingService.logWarning(
      `Unable to resolve ignore path: ${ignorePath} for ${fileName}`
    );
    return;
  }
  async getResolvedConfig(doc, vscodeConfig) {
    const fileName = doc.fileName;
    const prettier = await this.getPrettierInstance(fileName) ?? await getBundledPrettier();
    return this.resolveConfig(prettier, fileName, vscodeConfig);
  }
  async clearModuleCache(filePath) {
    const prettier = await this.getPrettierInstance(filePath) ?? await getBundledPrettier();
    try {
      await prettier.clearConfigCache();
    } catch (error) {
      this.loggingService.logError(
        `Failed to clear config cache for ${filePath}`,
        error
      );
    }
  }
  async findPrettierModule(fileName) {
    let dir;
    try {
      const stat = await fs2.promises.stat(fileName);
      dir = stat.isDirectory() ? fileName : path6.dirname(fileName);
    } catch {
      dir = path6.dirname(fileName);
    }
    const foundPath = await findUp(
      async (d) => {
        const nodeModulesDir = path6.join(d, "node_modules");
        const prettierPath = path6.join(nodeModulesDir, "prettier");
        if (await pathExists(prettierPath)) {
          return prettierPath;
        }
        if (await pathExists(nodeModulesDir)) {
          try {
            const entries = await fs2.promises.readdir(nodeModulesDir);
            for (const entry of entries) {
              if (entry.startsWith(".") || entry.startsWith("@")) {
                continue;
              }
              const nestedPrettierPath = path6.join(
                nodeModulesDir,
                entry,
                "node_modules",
                "prettier"
              );
              if (await pathExists(nestedPrettierPath)) {
                return nestedPrettierPath;
              }
            }
          } catch {
          }
        }
        if (await pathExists(path6.join(d, ".do-not-use-prettier-vscode-root"))) {
          return FIND_UP_STOP;
        }
        return void 0;
      },
      { cwd: dir }
    );
    return foundPath;
  }
  async findGlobalModule(moduleName) {
    const packageManagers = ["npm", "yarn", "pnpm"];
    for (const pm of packageManagers) {
      const globalPath = await globalPathGet(pm);
      if (globalPath) {
        const modulePath = path6.join(globalPath, moduleName);
        if (await pathExists(modulePath)) {
          return modulePath;
        }
      }
    }
    return void 0;
  }
  async isValidVersion(modulePath) {
    let modulePackageJsonPath = "";
    try {
      let packageDir = modulePath;
      try {
        const stat = await fs2.promises.stat(modulePath);
        if (stat.isFile()) {
          packageDir = path6.dirname(modulePath);
        }
      } catch {
      }
      modulePackageJsonPath = path6.join(packageDir, "package.json");
      const rawPkgJson = await fs2.promises.readFile(modulePackageJsonPath, {
        encoding: "utf8"
      });
      const pkgJson = JSON.parse(rawPkgJson);
      const version = pkgJson.version;
      if (!semver.gte(version, minPrettierVersion)) {
        this.loggingService.logError(OUTDATED_PRETTIER_VERSION_MESSAGE);
        this.loggingService.logInfo(
          `Found version ${version}, requires ${minPrettierVersion}+`
        );
        void window3.showWarningMessage(
          `Prettier: Version ${version} is outdated. Please upgrade to Prettier ${minPrettierVersion} or newer.`,
          "Learn More"
        ).then((selection) => {
          if (selection === "Learn More") {
            void commands.executeCommand(
              "vscode.open",
              Uri2.parse("https://prettier.io/docs/en/install")
            );
          }
        });
        await commands.executeCommand(
          "setContext",
          "prettier.outdatedError",
          true
        );
        return false;
      }
      await commands.executeCommand(
        "setContext",
        "prettier.outdatedError",
        false
      );
      return true;
    } catch {
      this.loggingService.logError(
        `${FAILED_TO_LOAD_MODULE_MESSAGE} ${modulePackageJsonPath}`
      );
      return false;
    }
  }
  async resolveConfig(prettierInstance, fileName, vscodeConfig) {
    let configPath;
    try {
      configPath = await prettierInstance.resolveConfigFile(fileName) ?? void 0;
    } catch (error) {
      this.loggingService.logError(
        `Failed to resolve config file for ${fileName}`,
        error
      );
      return "error";
    }
    if (configPath) {
      this.loggingService.logInfo(`Using config file at ${configPath}`);
    }
    if (vscodeConfig.useEditorConfig) {
      this.loggingService.logInfo(
        "EditorConfig support is enabled, checking for .editorconfig files"
      );
    }
    let resolvedConfig;
    try {
      const customConfigPath = vscodeConfig.configPath ? getWorkspaceRelativePath(fileName, vscodeConfig.configPath) : void 0;
      if (customConfigPath) {
        this.loggingService.logInfo(
          `Using custom config path from settings: ${customConfigPath}`
        );
      }
      const resolveConfigOptions = {
        config: customConfigPath ?? configPath,
        editorconfig: vscodeConfig.useEditorConfig
      };
      resolvedConfig = await prettierInstance.resolveConfig(
        fileName,
        resolveConfigOptions
      );
    } catch (error) {
      this.loggingService.logError(INVALID_PRETTIER_CONFIG, error);
      return "error";
    }
    if (resolvedConfig) {
      this.loggingService.logInfo("Resolved config:", resolvedConfig);
    }
    if (!configPath && resolvedConfig && vscodeConfig.useEditorConfig) {
      this.loggingService.logInfo(
        "No Prettier config file found, but settings were loaded from .editorconfig"
      );
    } else if (!configPath && !resolvedConfig) {
      this.loggingService.logInfo(
        "No local configuration (i.e. .prettierrc or .editorconfig) detected, will fall back to VS Code configuration"
      );
    }
    if (!vscodeConfig.requireConfig) {
      return resolvedConfig;
    }
    if (resolvedConfig) {
      return resolvedConfig;
    }
    if (!configPath) {
      this.loggingService.logInfo(
        "Require config set to true but no config file found, disabling formatting."
      );
      return "disabled";
    }
    return resolvedConfig;
  }
  dispose() {
    this.path2Module.clear();
  }
};

// src/PrettierEditService.ts
import * as path7 from "path";
import { pathToFileURL as pathToFileURL3 } from "url";
import {
  languages as languages2,
  Range as Range2,
  TextEdit as TextEdit2,
  window as window5,
  workspace as workspace3
} from "vscode";

// src/utils/get-parser-from-language.ts
function getParserFromLanguageId(languages3, uri, languageId) {
  const languageParsers = ["html", "json"];
  if (uri.scheme !== "file" && languageParsers.includes(languageId)) {
    return languageId;
  }
  const language = languages3.find(
    (lang) => lang && lang.extensions && Array.isArray(lang.vscodeLanguageIds) && lang.vscodeLanguageIds.includes(languageId)
  );
  if (language && language.parsers?.length > 0) {
    return language.parsers[0];
  }
}

// src/PrettierEditProvider.ts
var PrettierEditProvider = class {
  constructor(provideEdits) {
    this.provideEdits = provideEdits;
  }
  async provideDocumentRangeFormattingEdits(document, range, options, token) {
    return this.provideEdits(document, {
      rangeEnd: document.offsetAt(range.end),
      rangeStart: document.offsetAt(range.start),
      force: false
    });
  }
  async provideDocumentFormattingEdits(document, options, token) {
    return this.provideEdits(document, {
      force: false
    });
  }
};

// src/PrettierCodeActionProvider.ts
import {
  CodeAction,
  CodeActionKind,
  WorkspaceEdit
} from "vscode";
var PrettierCodeActionProvider = class {
  constructor(provideEdits) {
    this.provideEdits = provideEdits;
  }
  static providedCodeActionKinds = [
    CodeActionKind.SourceFixAll.append("prettier")
  ];
  async provideCodeActions(document, range, context, token) {
    const edits = await this.provideEdits(document, {
      force: false
    });
    if (edits.length === 0) {
      return [];
    }
    const action = new CodeAction(
      "Format with Prettier",
      CodeActionKind.SourceFixAll.append("prettier")
    );
    const workspaceEdit = new WorkspaceEdit();
    workspaceEdit.set(document.uri, edits);
    action.edit = workspaceEdit;
    return [action];
  }
};

// src/StatusBar.ts
import {
  languages,
  LanguageStatusSeverity,
  StatusBarAlignment,
  ThemeColor,
  window as window4
} from "vscode";
var StatusBar = class {
  statusBarItem;
  languageStatusItem;
  constructor() {
    this.statusBarItem = window4.createStatusBarItem(
      "prettier.status",
      StatusBarAlignment.Right,
      -1
    );
    this.languageStatusItem = languages.createLanguageStatusItem(
      "prettier.status",
      []
    );
    this.statusBarItem.name = "Prettier";
    this.statusBarItem.text = "Prettier";
    this.statusBarItem.command = "prettier.openOutput";
    this.update("check-all" /* Ready */);
    this.statusBarItem.show();
    this.languageStatusItem.name = "Prettier";
    this.languageStatusItem.text = "Prettier";
    this.languageStatusItem.command = {
      title: "View Logs",
      command: "prettier.openOutput"
    };
  }
  updateConfig({ selector }) {
    this.languageStatusItem.selector = selector;
  }
  /**
   * Update the statusBarItem message and show the statusBarItem
   *
   * @param icon The the icon to use
   */
  update(result) {
    this.statusBarItem.text = `$(${result.toString()}) Prettier`;
    switch (result) {
      case "x" /* Ignore */:
      case "warning" /* Warn */:
        this.statusBarItem.backgroundColor = new ThemeColor(
          "statusBarItem.warningBackground"
        );
        this.languageStatusItem.severity = LanguageStatusSeverity.Warning;
        break;
      case "alert" /* Error */:
        this.statusBarItem.backgroundColor = new ThemeColor(
          "statusBarItem.errorBackground"
        );
        this.languageStatusItem.severity = LanguageStatusSeverity.Error;
        break;
      default:
        this.statusBarItem.backgroundColor = new ThemeColor(
          "statusBarItem.fourgroundBackground"
        );
        this.languageStatusItem.severity = LanguageStatusSeverity.Information;
        break;
    }
    this.statusBarItem.show();
  }
  hide() {
    this.statusBarItem.hide();
  }
  dispose() {
    this.languageStatusItem.dispose();
    this.statusBarItem.dispose();
  }
};

// src/utils/versions.ts
var semver2 = __toESM(require_semver2(), 1);
function isAboveV3(version) {
  const parsedVersion = semver2.parse(version);
  if (!parsedVersion) {
    throw new Error("Invalid version");
  }
  return parsedVersion.major >= 3;
}

// src/PrettierEditService.ts
async function resolvePluginPaths(plugins, fileName, useFileUrls) {
  if (!plugins) {
    return [];
  }
  const dir = path7.dirname(fileName);
  const resolvedPlugins = [];
  for (const plugin of plugins) {
    if (typeof plugin !== "string") {
      resolvedPlugins.push(plugin);
      continue;
    }
    if (plugin.startsWith("file://") || plugin.startsWith("data:")) {
      resolvedPlugins.push(plugin);
      continue;
    }
    if (path7.isAbsolute(plugin)) {
      resolvedPlugins.push(useFileUrls ? pathToFileURL3(plugin).href : plugin);
      continue;
    }
    if (plugin.startsWith(".")) {
      const resolved = path7.resolve(dir, plugin);
      resolvedPlugins.push(
        useFileUrls ? pathToFileURL3(resolved).href : resolved
      );
      continue;
    }
    try {
      const resolved = resolveModuleEntry(dir, plugin);
      resolvedPlugins.push(
        useFileUrls ? pathToFileURL3(resolved).href : resolved
      );
    } catch {
      resolvedPlugins.push(plugin);
    }
  }
  return resolvedPlugins;
}
var PRETTIER_CONFIG_FILES = [
  ".prettierrc",
  ".prettierrc.json",
  ".prettierrc.json5",
  ".prettierrc.yaml",
  ".prettierrc.yml",
  ".prettierrc.toml",
  ".prettierrc.js",
  ".prettierrc.cjs",
  ".prettierrc.mjs",
  ".prettierrc.ts",
  ".prettierrc.cts",
  ".prettierrc.mts",
  "package.json",
  "prettier.config.js",
  "prettier.config.cjs",
  "prettier.config.mjs",
  "prettier.config.ts",
  "prettier.config.cts",
  "prettier.config.mts",
  ".editorconfig"
];
var PrettierEditService = class {
  constructor(moduleResolver, loggingService, statusBar) {
    this.moduleResolver = moduleResolver;
    this.loggingService = loggingService;
    this.statusBar = statusBar;
  }
  formatterHandler;
  rangeFormatterHandler;
  codeActionHandler;
  registeredWorkspaces = /* @__PURE__ */ new Set();
  allLanguages = [];
  allExtensions = [];
  allRangeLanguages = [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
    "jsonc",
    "graphql"
  ];
  registerDisposables() {
    const packageWatcher = workspace3.createFileSystemWatcher("**/package.json");
    packageWatcher.onDidChange(this.resetFormatters);
    packageWatcher.onDidCreate(this.resetFormatters);
    packageWatcher.onDidDelete(this.resetFormatters);
    const configurationWatcher = workspace3.onDidChangeConfiguration((event) => {
      if (event.affectsConfiguration("prettier.enable")) {
        this.loggingService.logWarning(RESTART_TO_ENABLE);
      } else if (event.affectsConfiguration("prettier")) {
        this.resetFormatters();
      }
    });
    const prettierConfigWatcher = workspace3.createFileSystemWatcher(
      `**/{${PRETTIER_CONFIG_FILES.join(",")}}`
    );
    prettierConfigWatcher.onDidChange(this.prettierConfigChanged);
    prettierConfigWatcher.onDidCreate(this.prettierConfigChanged);
    prettierConfigWatcher.onDidDelete(this.prettierConfigChanged);
    const textEditorChange = window5.onDidChangeActiveTextEditor(
      this.handleActiveTextEditorChangedSync
    );
    this.handleActiveTextEditorChangedSync(window5.activeTextEditor);
    return [
      packageWatcher,
      configurationWatcher,
      prettierConfigWatcher,
      textEditorChange
    ];
  }
  forceFormatDocument = async () => {
    try {
      const editor = window5.activeTextEditor;
      if (!editor) {
        this.loggingService.logInfo(
          "No active document. Nothing was formatted."
        );
        return;
      }
      this.loggingService.logInfo(
        "Forced formatting will not use ignore files."
      );
      const edits = await this.provideEdits(editor.document, { force: true });
      if (edits.length === 0) {
        this.loggingService.logInfo("Document is already formatted.");
        return;
      }
      if (edits.length > 1) {
        this.loggingService.logWarning(
          `Unexpected multiple edits (${edits.length}), expected 0 or 1`
        );
        return;
      }
      await editor.edit((editBuilder) => {
        editBuilder.replace(edits[0].range, edits[0].newText);
      });
    } catch (e) {
      this.loggingService.logError("Error formatting document", e);
    }
  };
  prettierConfigChanged = async (uri) => this.resetFormatters(uri);
  resetFormatters = (uri) => {
    if (uri) {
      const workspaceFolder = workspace3.getWorkspaceFolder(uri);
      this.registeredWorkspaces.delete(workspaceFolder?.uri.fsPath ?? "global");
    } else {
      this.registeredWorkspaces.clear();
    }
    this.statusBar.update("check-all" /* Ready */);
  };
  handleActiveTextEditorChangedSync = (textEditor) => {
    this.handleActiveTextEditorChanged(textEditor).catch((err) => {
      this.loggingService.logError("Error handling text editor change", err);
    });
  };
  handleActiveTextEditorChanged = async (textEditor) => {
    if (!textEditor) {
      this.statusBar.hide();
      return;
    }
    const { document } = textEditor;
    if (document.uri.scheme !== "file") {
      this.statusBar.update("check-all" /* Ready */);
      return;
    }
    const workspaceFolder = workspace3.getWorkspaceFolder(document.uri);
    if (!workspaceFolder) {
      return;
    }
    const prettierInstance = await this.moduleResolver.getPrettierInstance(
      workspaceFolder.uri.fsPath
    );
    const isRegistered = this.registeredWorkspaces.has(
      workspaceFolder.uri.fsPath
    );
    if (!prettierInstance) {
      this.statusBar.update("alert" /* Error */);
      return;
    }
    const selectors = await this.getSelectors(
      prettierInstance,
      document.uri,
      workspaceFolder.uri
    );
    this.statusBar.updateConfig({
      selector: selectors.languageSelector
    });
    if (!isRegistered) {
      this.registerDocumentFormatEditorProviders(selectors);
      this.registeredWorkspaces.add(workspaceFolder.uri.fsPath);
      this.loggingService.logDebug(
        `Enabling Prettier for Workspace ${workspaceFolder.uri.fsPath}`,
        selectors
      );
    }
    const score = languages2.match(selectors.languageSelector, document);
    if (score > 0) {
      this.statusBar.update("check-all" /* Ready */);
    } else {
      this.statusBar.update("circle-slash" /* Disabled */);
    }
  };
  async registerGlobal() {
    const instance = await this.moduleResolver.getGlobalPrettierInstance();
    const selectors = await this.getSelectors(instance);
    this.registerDocumentFormatEditorProviders(selectors);
    this.loggingService.logDebug("Enabling Prettier globally", selectors);
  }
  dispose = () => {
    this.moduleResolver.dispose();
    this.formatterHandler?.dispose();
    this.rangeFormatterHandler?.dispose();
    this.codeActionHandler?.dispose();
    this.formatterHandler = void 0;
    this.rangeFormatterHandler = void 0;
    this.codeActionHandler = void 0;
  };
  registerDocumentFormatEditorProviders({
    languageSelector,
    rangeLanguageSelector
  }) {
    this.dispose();
    const editProvider = new PrettierEditProvider(this.provideEdits);
    const codeActionProvider = new PrettierCodeActionProvider(
      this.provideEdits
    );
    this.rangeFormatterHandler = languages2.registerDocumentRangeFormattingEditProvider(
      rangeLanguageSelector,
      editProvider
    );
    this.formatterHandler = languages2.registerDocumentFormattingEditProvider(
      languageSelector,
      editProvider
    );
    this.codeActionHandler = languages2.registerCodeActionsProvider(
      languageSelector,
      codeActionProvider,
      {
        providedCodeActionKinds: PrettierCodeActionProvider.providedCodeActionKinds
      }
    );
  }
  /**
   * Build formatter selectors
   */
  getSelectors = async (prettierInstance, documentUri, workspaceFolderUri) => {
    let plugins = [];
    if (documentUri && "resolveConfig" in prettierInstance && isAboveV3(prettierInstance.version)) {
      const resolvedConfig = await this.moduleResolver.resolveConfig(
        prettierInstance,
        documentUri.fsPath,
        getWorkspaceConfig(documentUri)
      );
      if (resolvedConfig === "error") {
        this.statusBar.update("alert" /* Error */);
      } else if (resolvedConfig === "disabled") {
        this.statusBar.update("circle-slash" /* Disabled */);
      } else if (resolvedConfig?.plugins) {
        plugins = await resolvePluginPaths(
          resolvedConfig.plugins,
          documentUri.fsPath,
          true
          // Use file:// URLs for Prettier v3+
        );
      }
    }
    const { languages: languages3 } = await prettierInstance.getSupportInfo({
      plugins
    });
    languages3.forEach((lang) => {
      if (lang && lang.vscodeLanguageIds) {
        this.allLanguages.push(...lang.vscodeLanguageIds);
      }
    });
    this.allLanguages = this.allLanguages.filter((value, index, self) => {
      return self.indexOf(value) === index;
    });
    languages3.forEach((lang) => {
      if (lang && lang.extensions) {
        this.allExtensions.push(...lang.extensions);
      }
    });
    this.allExtensions = this.allExtensions.filter((value, index, self) => {
      return self.indexOf(value) === index;
    });
    const { documentSelectors } = getWorkspaceConfig();
    const extensionLanguageSelector = workspaceFolderUri ? this.allExtensions.length === 0 ? [] : [
      {
        pattern: `${workspaceFolderUri.fsPath}/**/*.{${this.allExtensions.map((e) => e.substring(1)).join(",")}}`,
        scheme: "file"
      }
    ] : [];
    const customLanguageSelectors = workspaceFolderUri ? documentSelectors.map((pattern) => ({
      pattern: `${workspaceFolderUri.fsPath}/${pattern}`,
      scheme: "file"
    })) : [];
    const defaultLanguageSelectors = [
      ...this.allLanguages.map((language) => ({ language })),
      { language: "jsonc", scheme: "vscode-userdata" }
      // Selector for VSCode settings.json
    ];
    const languageSelector = [
      ...customLanguageSelectors,
      ...extensionLanguageSelector,
      ...defaultLanguageSelectors
    ];
    const rangeLanguageSelector = [
      ...this.allRangeLanguages.map((language) => ({
        language
      }))
    ];
    return { languageSelector, rangeLanguageSelector };
  };
  provideEdits = async (document, options) => {
    const startTime = (/* @__PURE__ */ new Date()).getTime();
    const result = await this.format(document.getText(), document, options);
    if (!result) {
      return [];
    }
    const duration = (/* @__PURE__ */ new Date()).getTime() - startTime;
    this.loggingService.logInfo(`Formatting completed in ${duration}ms.`);
    const edit = this.minimalEdit(document, result);
    if (!edit) {
      this.loggingService.logDebug(
        "Document is already formatted, no changes needed."
      );
      return [];
    }
    return [edit];
  };
  minimalEdit(document, string1) {
    const string0 = document.getText();
    if (string0 === string1) {
      return null;
    }
    let i = 0;
    while (i < string0.length && i < string1.length && string0[i] === string1[i]) {
      ++i;
    }
    let j = 0;
    while (i + j < string0.length && i + j < string1.length && string0[string0.length - j - 1] === string1[string1.length - j - 1]) {
      ++j;
    }
    const newText = string1.substring(i, string1.length - j);
    const pos0 = document.positionAt(i);
    const pos1 = document.positionAt(string0.length - j);
    return TextEdit2.replace(new Range2(pos0, pos1), newText);
  }
  /**
   * Format the given text with user's configuration.
   * @param text Text to format
   * @param path formatting file's path
   * @returns {string} formatted text
   */
  async format(text, doc, options) {
    const { fileName, uri, languageId } = doc;
    this.loggingService.logInfo(`Formatting ${uri}`);
    const vscodeConfig = getWorkspaceConfig(doc);
    const resolvedConfig = await this.moduleResolver.getResolvedConfig(
      doc,
      vscodeConfig
    );
    if (resolvedConfig === "error") {
      this.statusBar.update("alert" /* Error */);
      return;
    }
    if (resolvedConfig === "disabled") {
      this.statusBar.update("circle-slash" /* Disabled */);
      return;
    }
    const prettierInstance = await this.moduleResolver.getPrettierInstance(fileName);
    this.loggingService.logInfo("PrettierInstance:", prettierInstance);
    if (!prettierInstance) {
      this.loggingService.logError(
        "Prettier could not be loaded. See previous logs for more information."
      );
      this.statusBar.update("alert" /* Error */);
      return;
    }
    let resolvedIgnorePath;
    if (vscodeConfig.ignorePath) {
      resolvedIgnorePath = await this.moduleResolver.getResolvedIgnorePath(
        fileName,
        vscodeConfig.ignorePath
      );
      if (resolvedIgnorePath) {
        this.loggingService.logInfo(
          `Using ignore file (if present) at ${resolvedIgnorePath}`
        );
      }
    }
    const useFileUrls = isAboveV3(prettierInstance.version);
    const resolvedPlugins = await resolvePluginPaths(
      resolvedConfig?.plugins,
      fileName,
      useFileUrls
    );
    this.loggingService.logInfo("Resolved plugins:", resolvedPlugins);
    let fileInfo;
    if (uri.scheme === "file") {
      fileInfo = await prettierInstance.getFileInfo(fileName, {
        ignorePath: resolvedIgnorePath,
        plugins: resolvedPlugins,
        resolveConfig: false,
        withNodeModules: vscodeConfig.withNodeModules
      });
      this.loggingService.logInfo("File Info:", fileInfo);
    }
    if (!options.force && fileInfo && fileInfo.ignored) {
      this.loggingService.logInfo("File is ignored, skipping.");
      this.statusBar.update("x" /* Ignore */);
      return;
    }
    let parser;
    if (fileInfo && fileInfo.inferredParser) {
      parser = fileInfo.inferredParser;
    } else if (resolvedConfig && resolvedConfig.parser) {
      parser = resolvedConfig.parser;
    } else if (languageId !== "plaintext") {
      this.loggingService.logWarning(
        `Parser not inferred, trying VS Code language.`
      );
      const { languages: languages3 } = await prettierInstance.getSupportInfo({
        plugins: resolvedPlugins
      });
      parser = getParserFromLanguageId(languages3, uri, languageId);
    }
    if (!parser) {
      this.loggingService.logError(
        `Failed to resolve a parser, skipping file. If you registered a custom file extension, be sure to configure the parser.`
      );
      this.statusBar.update("alert" /* Error */);
      return;
    }
    const prettierOptions = this.getPrettierOptions(
      fileName,
      parser,
      vscodeConfig,
      resolvedConfig,
      options,
      resolvedPlugins
    );
    this.loggingService.logInfo("Prettier Options:", prettierOptions);
    try {
      const formattedText = await prettierInstance.format(
        text,
        prettierOptions
      );
      this.statusBar.update("check" /* Success */);
      return formattedText;
    } catch (error) {
      this.loggingService.logError("Error formatting document.", error);
      this.statusBar.update("alert" /* Error */);
      return text;
    }
  }
  getPrettierOptions(fileName, parser, vsCodeConfig, configOptions, extensionFormattingOptions, resolvedPlugins) {
    const fallbackToVSCodeConfig = configOptions === null;
    const vsOpts = {};
    if (fallbackToVSCodeConfig) {
      vsOpts.arrowParens = vsCodeConfig.arrowParens;
      vsOpts.bracketSpacing = vsCodeConfig.bracketSpacing;
      vsOpts.endOfLine = vsCodeConfig.endOfLine;
      vsOpts.htmlWhitespaceSensitivity = vsCodeConfig.htmlWhitespaceSensitivity;
      vsOpts.insertPragma = vsCodeConfig.insertPragma;
      vsOpts.singleAttributePerLine = vsCodeConfig.singleAttributePerLine;
      vsOpts.bracketSameLine = vsCodeConfig.bracketSameLine;
      vsOpts.jsxBracketSameLine = vsCodeConfig.jsxBracketSameLine;
      vsOpts.jsxSingleQuote = vsCodeConfig.jsxSingleQuote;
      vsOpts.printWidth = vsCodeConfig.printWidth;
      vsOpts.proseWrap = vsCodeConfig.proseWrap;
      vsOpts.quoteProps = vsCodeConfig.quoteProps;
      vsOpts.requirePragma = vsCodeConfig.requirePragma;
      vsOpts.semi = vsCodeConfig.semi;
      vsOpts.singleQuote = vsCodeConfig.singleQuote;
      vsOpts.tabWidth = vsCodeConfig.tabWidth;
      vsOpts.trailingComma = vsCodeConfig.trailingComma;
      vsOpts.useTabs = vsCodeConfig.useTabs;
      vsOpts.embeddedLanguageFormatting = vsCodeConfig.embeddedLanguageFormatting;
      vsOpts.vueIndentScriptAndStyle = vsCodeConfig.vueIndentScriptAndStyle;
      vsOpts.experimentalTernaries = vsCodeConfig.experimentalTernaries;
      vsOpts.objectWrap = vsCodeConfig.objectWrap;
      vsOpts.experimentalOperatorPosition = vsCodeConfig.experimentalOperatorPosition;
    }
    this.loggingService.logInfo(
      fallbackToVSCodeConfig ? "Using VS Code configuration" : "Using local configuration (VS Code configuration will not be used)"
    );
    let rangeFormattingOptions;
    if (extensionFormattingOptions.rangeEnd && extensionFormattingOptions.rangeStart) {
      rangeFormattingOptions = {
        rangeEnd: extensionFormattingOptions.rangeEnd,
        rangeStart: extensionFormattingOptions.rangeStart
      };
    }
    const options = {
      ...fallbackToVSCodeConfig ? vsOpts : {},
      ...{
        /* cspell: disable-next-line */
        filepath: fileName,
        parser
      },
      ...rangeFormattingOptions || {},
      ...configOptions || {},
      // Pass resolved plugin paths for Prettier to import
      ...resolvedPlugins.length > 0 ? { plugins: resolvedPlugins } : {}
    };
    if (extensionFormattingOptions.force && options.requirePragma === true) {
      options.requirePragma = false;
    }
    return options;
  }
};

// src/TemplateService.ts
import { TextEncoder } from "util";
import { Uri as Uri4, workspace as workspace4 } from "vscode";
var TemplateService = class {
  constructor(loggingService, prettierModulePromise) {
    this.loggingService = loggingService;
    this.prettierModulePromise = prettierModulePromise;
  }
  async writeConfigFile(folderPath) {
    const settings = { tabWidth: 2, useTabs: false };
    const outputPath = Uri4.joinPath(folderPath, ".prettierrc");
    const formatterOptions = {
      /* cspell: disable-next-line */
      filepath: outputPath.scheme === "file" ? outputPath.fsPath : void 0,
      tabWidth: settings.tabWidth,
      useTabs: settings.useTabs
    };
    const prettierModule2 = await this.prettierModulePromise;
    const templateSource = await prettierModule2.format(
      JSON.stringify(settings, null, 2),
      formatterOptions
    );
    this.loggingService.logInfo(`Writing .prettierrc to ${outputPath}`);
    await workspace4.fs.writeFile(
      outputPath,
      new TextEncoder().encode(templateSource)
    );
  }
};

// src/extension.ts
var extensionName = "esbenp.prettier-vscode";
var extensionVersion = "12.1.1";
async function activate(context) {
  const loggingService = new LoggingService();
  loggingService.logInfo(`Extension Name: ${extensionName}.`);
  loggingService.logInfo(`Extension Version: ${extensionVersion}.`);
  const { enable, enableDebugLogs } = getWorkspaceConfig();
  if (enableDebugLogs) {
    loggingService.setOutputLevel("DEBUG");
  }
  if (!enable) {
    loggingService.logInfo(EXTENSION_DISABLED);
    context.subscriptions.push(
      workspace5.onDidChangeConfiguration((event) => {
        if (event.affectsConfiguration("prettier.enable")) {
          loggingService.logWarning(RESTART_TO_ENABLE);
        }
      })
    );
    return;
  }
  const moduleResolver = new ModuleResolver(loggingService);
  const prettierPromise = moduleResolver.getGlobalPrettierInstance();
  const templateService = new TemplateService(loggingService, prettierPromise);
  const statusBar = new StatusBar();
  const editService = new PrettierEditService(
    moduleResolver,
    loggingService,
    statusBar
  );
  await editService.registerGlobal();
  const createConfigFileFunc = createConfigFile(templateService);
  const createConfigFileCommand = commands2.registerCommand(
    "prettier.createConfigFile",
    createConfigFileFunc
  );
  const openOutputCommand = commands2.registerCommand(
    "prettier.openOutput",
    () => {
      loggingService.show();
    }
  );
  const forceFormatDocumentCommand = commands2.registerCommand(
    "prettier.forceFormatDocument",
    editService.forceFormatDocument
  );
  context.subscriptions.push(
    statusBar,
    editService,
    createConfigFileCommand,
    openOutputCommand,
    forceFormatDocumentCommand,
    ...editService.registerDisposables()
  );
}
export {
  activate
};
//# sourceMappingURL=extension.js.map
