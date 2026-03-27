# Storage

Type

emptyDirDescription
Empty directory in Pod with read/write access. Persisted for only the lifespan of a Pod. A good choice for
cache implementations or data exchange between containers of a Pod.
hostPathFile or directory from the host node’s filesystem.
configMap,
secretProvides a way to inject configuration data. For practical examples, see “Defining and Consuming
Configuration Data” on page 60.
nfsAn existing Network File System (NFS) share. Preserves data after Pod restart.
persistent
VolumeClaimC


Access type

ReadWriteOnce
Short Form Description
RWO
Read/write access by a single node
ReadOnlyManyROXRead-only access by many nodes
ReadWriteManyRWXRead/write access by many nodes
ReadWriteOncePod RWOP
Read/write access mounted by a single Pod


Storage Classes it's dynamic pv
