Main command line entry point.

    docopt = require 'docopt'
    path = require 'path'
    fs = require 'fs'
    wrench = require 'wrench'
    crypto = require 'cryptojs'

Actual command line processing via docopt.

    require.extensions['.docopt'] = (module, filename) ->
        doc = fs.readFileSync filename, 'utf8'
        module.exports =
            options: docopt.docopt doc, version: require('../package.json').version
            help: doc
    cli = require './cli.docopt'

Full on help

    if cli.options['--help']
        console.log cli.help

Root directory needs to be in the environment

    cli.options.rootpath = path.resolve cli.options['--directory'] or process.env['TOKEN_ROOT'] or process.cwd()
    cli.options.datapath = path.join cli.options.rootpath, 'data'
    cli.options.tokenpath = path.join cli.options.rootpath, 'token'

The various sub commands are here.

    init = (options) ->
        if not fs.existsSync options.rootpath
            wrench.mkdirSyncRecursive options.rootpath
        if not fs.existsSync options.datapath
            wrench.mkdirSyncRecursive options.datapath
        if not fs.existsSync options.tokenpath
            wrench.mkdirSyncRecursive options.tokenpath

    data = (options) ->
        stream = fs.createWriteStream path.join(options.datapath, options['<data_name>'])
        stream.on 'error', ->
            console.error arguments
        stream.on 'open', ->
            process.stdin.on 'data', (chunk) ->
                process.stdout.write chunk
                stream.write chunk
            process.stdin.on 'end', ->
                stream.end()
            process.stdin.resume()

    create = (options) ->
        datapath = path.join options.datapath, options['<data_name>']
        fs.readFile datapath, 'utf8', (err, data) ->
            if err
                console.error err
            token = crypto.Crypto.SHA256 "#{data}#{Date.now()}"
            tokenpath = path.join options.tokenpath, token
            fs.link datapath, tokenpath, (err) ->
                if err
                    console.log err
                process.stdout.write token

    decode = (options) ->
        tokenpath = path.join options.tokenpath, options['<token>']
        fs.readFile tokenpath, 'utf8', (err, data) ->
            if err
                if err.code is 'ENOENT'
                    process.exit 2
                else
                    console.error err
                    process.exit 1
            process.stdout.write data

Main entry point, handing off to the sub commands

    cli.options.init and init cli.options
    cli.options.data and data cli.options
    cli.options.create and create cli.options
    cli.options.decode and decode cli.options
