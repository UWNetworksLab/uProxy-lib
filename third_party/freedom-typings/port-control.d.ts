/// <reference path="../../../build/third_party/typings/es6-promise/es6-promise.d.ts" />

declare module freedom_PortControl {
    // Object representing a port mapping
    interface Mapping {
        internalIp :string;
        internalPort :number;
        externalIp ?:string;
        externalPort :number;
        lifetime :number;
        protocol :string;
        timeoutId ?:number;
        nonce ?:number[];
        errInfo ?:string;
    }
    // A collection of Mappings
    interface ActiveMappings {
        [extPort :string] :Mapping;
    }
    // An object returned by probeProtocolSupport()
    interface ProtocolSupport {
        natPmp :boolean;
        pcp :boolean;
        upnp :boolean;
    }
    // Main interface for the module
    interface PortControl {
        addMapping(intPort:number, extPort:number, lifetime:number) :Promise<Mapping>;
        deleteMapping(extPort:number) :Promise<boolean>;
        probeProtocolSupport() :Promise<ProtocolSupport>;

        probePmpSupport() :Promise<boolean>;
        addMappingPmp(intPort:number, extPort:number, lifetime:number) :Promise<Mapping>;
        deleteMappingPmp(extPort:number) :Promise<boolean>;

        probePcpSupport() :Promise<boolean>;
        addMappingPcp(intPort:number, extPort:number, lifetime:number) :Promise<Mapping>;
        deleteMappingPcp(extPort:number) :Promise<boolean>;

        probeUpnpSupport() :Promise<boolean>;
        addMappingUpnp(intPort:number, extPort:number, lifetime:number, 
                       controlUrl?:string) :Promise<Mapping>;
        deleteMappingUpnp(extPort:number) :Promise<boolean>;

        getActiveMappings() :Promise<ActiveMappings>;
        getPrivateIps() :Promise<string[]>;
        close() :Promise<void>;
    }
}
