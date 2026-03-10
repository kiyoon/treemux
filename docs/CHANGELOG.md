# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.2.1] - 2026-03-10
### :bug: Bug Fixes
- [`9b6d13f`](https://github.com/kiyoon/treemux/commit/9b6d13f313c5b6760cb1a0f9887e8a30601b4563) - nvim-tree sidebar opening at parent directory *(PR [#17](https://github.com/kiyoon/treemux/pull/17) by [@kiyoon](https://github.com/kiyoon))*
  - :arrow_lower_right: *fixes issue [#16](https://github.com/kiyoon/treemux/issues/16) opened by [@zhiyuanzhai](https://github.com/zhiyuanzhai)*


## [v0.2.0] - 2025-08-11
### :key: Key Features
- Support for [Neo-Tree](https://github.com/nvim-neo-tree/neo-tree.nvim)
- Switch to [Oil.nvim](https://github.com/stevearc/oil.nvim) to easily move files and going back to the original tree

### :boom: BREAKING CHANGES
- due to [`c936b69`](https://github.com/kiyoon/treemux/commit/c936b697ce5f46d6bae390ffc79295c2aa6cab2c) - make /usr/bin/python3 default *(commit by [@kiyoon](https://github.com/kiyoon))*:

  make /usr/bin/python3 default


### :sparkles: New Features
- [`6a3b35d`](https://github.com/kiyoon/treemux/commit/6a3b35d8241c4f6f39f83af09df6fc1d2e16ced9) - use tmux-send.nvim *(commit by [@kiyoon](https://github.com/kiyoon))*
- [`6dcf316`](https://github.com/kiyoon/treemux/commit/6dcf31671ab9fd140e89dd1d2e0f4bbab1ff325d) - Neo-Tree *(PR [#13](https://github.com/kiyoon/treemux/pull/13) by [@kiyoon](https://github.com/kiyoon))*

### :bug: Bug Fixes
- [`07a4a07`](https://github.com/kiyoon/treemux/commit/07a4a0785b1cb6dca1715f01903e78205de38fba) - correctly configure python path *(commit by [@kiyoon](https://github.com/kiyoon))*
- [`c936b69`](https://github.com/kiyoon/treemux/commit/c936b697ce5f46d6bae390ffc79295c2aa6cab2c) - make /usr/bin/python3 default *(commit by [@kiyoon](https://github.com/kiyoon))*
- [`05bd218`](https://github.com/kiyoon/treemux/commit/05bd218b0882dc2c2f82b4c5e7a5d98224ba04eb) - wrong plugin *(commit by [@kiyoon](https://github.com/kiyoon))*

[v0.2.0]: https://github.com/kiyoon/treemux/compare/v0.1.1...v0.2.0
[v0.2.1]: https://github.com/kiyoon/treemux/compare/v0.2.0...v0.2.1
